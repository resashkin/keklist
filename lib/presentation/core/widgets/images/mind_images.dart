import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keklist/presentation/core/widgets/native_glass_cover.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/services/analytics/analytics.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/helpers/media_sources.dart';
import 'package:keklist/presentation/core/helpers/phone_orientation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

/// What came of a gallery pick: the saved photos and videos, and how many videos were too long to attach.
typedef GalleryPick = ({List<MindNoteImage> images, int tooLongVideos});

/// Picks photos and videos for a mind and keeps copies in `user_files/image`. See `documentation/MIND_IMAGES.md`.
final class MindImageAttaching {
  static const double _maxSide = 2048.0;
  static const int _quality = 85;

  static Future<GalleryPick> pickFromGallery(BuildContext context, {required int limit}) async {
    if (limit <= 0) return (images: const <MindNoteImage>[], tooLongVideos: 0);
    final AppFileRepository files = context.read<AppFileRepository>();
    final ImagePicker picker = ImagePicker();
    final List<XFile> picked = limit == 1
        ? [?await picker.pickMedia(maxWidth: _maxSide, maxHeight: _maxSide, imageQuality: _quality)]
        : await picker.pickMultipleMedia(maxWidth: _maxSide, maxHeight: _maxSide, imageQuality: _quality, limit: limit);
    final List<XFile> chosen = picked.take(limit).toList();
    if (!chosen.any(_isVideo) || !context.mounted) return (images: await _save(files, chosen), tooLongVideos: 0);
    // Compressing takes a few seconds per video, so the screen says so meanwhile.
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    unawaited(
      showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              spacing: 16.0,
              children: [
                const CircularProgressIndicator.adaptive(),
                Expanded(child: Text(context.l10n.videoCompressing)),
              ],
            ),
          ),
        ),
      ),
    );
    final List<MindNoteImage> images = [];
    int tooLong = 0;
    try {
      for (final XFile file in chosen) {
        if (!_isVideo(file)) {
          images.addAll(await _save(files, [file]));
          continue;
        }
        final MindNoteImage? video = await _saveVideo(files, file);
        if (video == null) {
          tooLong += await _isTooLong(file) ? 1 : 0;
        } else {
          images.add(video);
        }
      }
    } finally {
      navigator.pop();
    }
    return (images: images, tooLongVideos: tooLong);
  }

  static bool _isVideo(XFile file) =>
      MindNoteImage(appRelativePath: file.name).isVideo || (file.mimeType?.startsWith('video/') ?? false);

  static Future<bool> _isTooLong(XFile file) async {
    final MediaInfo info = await VideoCompress.getMediaInfo(file.path);
    return (info.duration ?? 0.0) > kMaxAttachedVideoLength.inMilliseconds + 500;
  }

  /// Squeezes the video to 720p and keeps its first frame next to it; null when it is too long or fails.
  static Future<MindNoteImage?> _saveVideo(AppFileRepository files, XFile file) async {
    try {
      if (await _isTooLong(file)) return null;
      final MediaInfo? compressed = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.Res1280x720Quality,
        includeAudio: true,
      );
      final String? output = compressed?.path;
      if (output == null) return null;
      final Uint8List? frame = await VideoCompress.getByteThumbnail(output, quality: 85, position: 0);
      final String name = const Uuid().v4();
      final String path = await files.moveIntoImages(File(output), extension: output.split('.').last, name: name);
      if (frame != null) {
        final File temporary = File('${Directory.systemTemp.path}/$name.jpg');
        await temporary.writeAsBytes(frame, flush: true);
        await files.moveIntoImages(temporary, extension: 'jpg', name: name);
      }
      return MindNoteImage(appRelativePath: path);
    } catch (_) {
      return null;
    } finally {
      unawaited(VideoCompress.deleteAllCache());
    }
  }

  static Future<List<MindNoteImage>> takePhoto(BuildContext context) async {
    final AppFileRepository files = context.read<AppFileRepository>();
    final XFile? photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: _quality,
    );
    return _save(files, [?photo]);
  }

  static Future<MindNoteImage?> fromAsset(AppFileRepository files, AssetEntity asset) async {
    final Uint8List? bytes = await asset.thumbnailDataWithSize(
      const ThumbnailSize(2048, 2048),
      format: ThumbnailFormat.jpeg,
      quality: _quality,
    );
    if (bytes == null) return null;
    return MindNoteImage(appRelativePath: await files.saveImage(bytes));
  }

  /// Images never saved into a mind are removed right away.
  static Future<void> discard(AppFileRepository files, Iterable<MindNoteImage> images) async {
    for (final MindNoteImage image in images) {
      for (final String path in {image.appRelativePath, image.previewRelativePath}) {
        final File file = File(await files.resolveAbsolutePath(path));
        if (await file.exists()) await file.delete();
      }
    }
  }

  static Future<List<MindNoteImage>> _save(AppFileRepository files, Iterable<XFile> picked) async {
    final List<MindNoteImage> images = [];
    for (final XFile file in picked) {
      final String extension = switch (file.name.split('.').last.toLowerCase()) {
        'png' => 'png',
        'gif' => 'gif',
        'heic' => 'heic',
        _ => 'jpg',
      };
      images.add(MindNoteImage(appRelativePath: await files.saveImage(await file.readAsBytes(), extension: extension)));
    }
    return images;
  }
}

/// Asks where the photos come from and returns the saved ones; gallery videos come along, squeezed.
Future<List<MindNoteImage>> pickMindImages(
  BuildContext context, {
  required int limit,
  required ImageAttachTarget target,
}) async {
  final ImageSource? source = await showModalActionSheet<ImageSource>(
    context: context,
    cancelLabel: context.l10n.cancel,
    actions: [
      SheetAction(key: ImageSource.gallery, label: context.l10n.imageFromGallery, icon: Icons.photo_library_outlined),
      SheetAction(key: ImageSource.camera, label: context.l10n.imageFromCamera, icon: Icons.photo_camera_outlined),
    ],
  );
  if (source == null || !context.mounted) return const [];
  final GalleryPick pick = switch (source) {
    ImageSource.gallery => await MindImageAttaching.pickFromGallery(context, limit: limit),
    ImageSource.camera => (images: await MindImageAttaching.takePhoto(context), tooLongVideos: 0),
  };
  final List<MindNoteImage> images = pick.images;
  if (pick.tooLongVideos > 0 && context.mounted) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(context.l10n.videoTooLong(kMaxAttachedVideoLength.inSeconds))),
    );
  }
  Analytics.imagesAttached(
    images.length,
    source: source == ImageSource.camera ? ImageAttachSource.camera : ImageAttachSource.gallery,
    target: target,
  );
  return images;
}

/// One attached image, loaded from the app files (or the phone, in the web version).
final class MindImageView extends StatelessWidget {
  final MindNoteImage image;
  final BoxFit fit;
  final int? cacheWidth;

  const MindImageView({super.key, required this.image, this.fit = BoxFit.cover, this.cacheWidth});

  @override
  Widget build(BuildContext context) {
    final Widget preview = FutureBuilder<String>(
      future: context.read<AppFileRepository>().resolveAbsolutePath(image.previewRelativePath),
      builder: (context, snapshot) {
        final String? path = snapshot.data;
        if (path == null) return const SizedBox.shrink();
        return imageFor(
          path,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          cacheWidth: cacheWidth,
          errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white38)),
        );
      },
    );
    if (!image.isVideo) return preview;
    return Stack(
      fit: StackFit.expand,
      children: [
        preview,
        const Center(
          child: FractionallySizedBox(
            widthFactor: 0.28,
            child: FittedBox(
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                child: Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(Icons.play_arrow_rounded, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Images full-screen: swipe between them, pinch to zoom, drag down to close.
final class MindImagesFullscreen extends StatefulWidget {
  final List<MindNoteImage> images;
  final int initialIndex;

  const MindImagesFullscreen({super.key, required this.images, this.initialIndex = 0});

  static Future<void> show(BuildContext context, List<MindNoteImage> images, {int initialIndex = 0}) =>
      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder<void>(
          opaque: false,
          barrierColor: Colors.transparent,
          pageBuilder: (_, _, _) => MindImagesFullscreen(images: images, initialIndex: initialIndex),
          transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
        ),
      );

  @override
  State<MindImagesFullscreen> createState() => _MindImagesFullscreenState();
}

final class _MindImagesFullscreenState extends State<MindImagesFullscreen> {
  static const double _dismissDistance = 120.0;

  late final PageController _pages = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  final List<TransformationController> _zooms = [];
  bool _isZoomed = false;
  double _dragY = 0.0;
  final VoidCallback _endRotation = PhoneOrientation.allowRotation();

  TransformationController _zoomAt(int index) {
    while (_zooms.length <= index) {
      _zooms.add(TransformationController());
    }
    return _zooms[index];
  }

  @override
  void dispose() {
    _endRotation();
    _pages.dispose();
    for (final TransformationController zoom in _zooms) {
      zoom.dispose();
    }
    super.dispose();
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (_isZoomed || details.pointerCount > 1) return;
    setState(() => _dragY += details.focalPointDelta.dy);
  }

  void _onInteractionEnd(int index) {
    final bool isZoomed = _zoomAt(index).value.getMaxScaleOnAxis() > 1.01;
    if (!isZoomed && _dragY.abs() > _dismissDistance) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isZoomed = isZoomed;
      _dragY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double fade = (1.0 - _dragY.abs() / (_dismissDistance * 3)).clamp(0.3, 1.0);
    return NativeGlassCover(
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: fade),
        body: Stack(
          children: [
            Transform.translate(
              offset: Offset(0.0, _dragY),
              child: PageView.builder(
                controller: _pages,
                physics: _isZoomed ? const NeverScrollableScrollPhysics() : null,
                itemCount: widget.images.length,
                onPageChanged: (index) => setState(() {
                  _index = index;
                  _isZoomed = false;
                }),
                itemBuilder: (_, index) => widget.images[index].isVideo
                    ? GestureDetector(
                        onVerticalDragUpdate: (details) => setState(() => _dragY += details.delta.dy),
                        onVerticalDragEnd: (_) => _onInteractionEnd(index),
                        child: _FullscreenVideo(video: widget.images[index], isCurrent: index == _index),
                      )
                    : InteractiveViewer(
                        transformationController: _zoomAt(index),
                        maxScale: 5.0,
                        onInteractionUpdate: _onInteractionUpdate,
                        onInteractionEnd: (_) => _onInteractionEnd(index),
                        child: MindImageView(image: widget.images[index], fit: BoxFit.contain),
                      ),
              ),
            ),
            SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  if (widget.images.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text(
                        '${_index + 1}/${widget.images.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An attached gallery video full-screen: plays with sound and loops while its page is showing; a tap pauses it.
final class _FullscreenVideo extends StatefulWidget {
  final MindNoteImage video;
  final bool isCurrent;

  const _FullscreenVideo({required this.video, required this.isCurrent});

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

final class _FullscreenVideoState extends State<_FullscreenVideo> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final String path = await context.read<AppFileRepository>().resolveAbsolutePath(widget.video.appRelativePath);
    final VideoPlayerController controller = videoControllerFor(path);
    try {
      await controller.initialize();
      await controller.setLooping(true);
    } catch (_) {
      await controller.dispose();
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
    if (widget.isCurrent) await controller.play();
  }

  @override
  void didUpdateWidget(_FullscreenVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCurrent == widget.isCurrent) return;
    widget.isCurrent ? _controller?.play() : _controller?.pause();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;
    if (controller == null) return MindImageView(image: widget.video, fit: BoxFit.contain);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.value.isPlaying ? controller.pause() : controller.play(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller)),
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller,
            builder: (_, value, _) => value.isPlaying
                ? const SizedBox.shrink()
                : Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40.0),
                  ),
          ),
        ],
      ),
    );
  }
}

/// The images of a story: a card to swipe through, with dots; past the last image the swipe goes on to [onSwipePastEdge].
final class MindImageCarousel extends StatefulWidget {
  /// How long each photo stays before the next one turns in by itself.
  static const Duration autoplayInterval = Duration(seconds: 3);

  final List<MindNoteImage> images;

  /// Turns the photos by themselves while true, stopping on the last one.
  final bool isAutoplaying;
  final ValueChanged<AxisDirection>? onSwipePastEdge;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  const MindImageCarousel({
    super.key,
    required this.images,
    this.isAutoplaying = false,
    this.onSwipePastEdge,
    this.onOpen,
    this.onClose,
  });

  @override
  State<MindImageCarousel> createState() => _MindImageCarouselState();
}

final class _MindImageCarouselState extends State<MindImageCarousel> {
  static const double _edgeSwipeDistance = 40.0;

  final PageController _pages = PageController();
  int _index = 0;
  double _overscroll = 0.0;
  bool _handedOver = false;
  Timer? _autoplay;

  @override
  void initState() {
    super.initState();
    _scheduleNext();
  }

  @override
  void didUpdateWidget(MindImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isAutoplaying != widget.isAutoplaying) _scheduleNext();
  }

  @override
  void dispose() {
    _autoplay?.cancel();
    _pages.dispose();
    super.dispose();
  }

  void _scheduleNext() {
    _autoplay?.cancel();
    if (!widget.isAutoplaying || _index >= widget.images.length - 1) return;
    _autoplay = Timer(MindImageCarousel.autoplayInterval, () {
      if (!_pages.hasClients) return;
      _pages.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    });
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    _scheduleNext();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _overscroll = 0.0;
      _handedOver = false;
    }
    if (notification is OverscrollNotification && notification.dragDetails != null && !_handedOver) {
      _overscroll += notification.overscroll;
      if (_overscroll.abs() > _edgeSwipeDistance) {
        _handedOver = true;
        widget.onSwipePastEdge?.call(_overscroll > 0 ? AxisDirection.right : AxisDirection.left);
      }
    }
    return true;
  }

  Future<void> _open() async {
    widget.onOpen?.call();
    await MindImagesFullscreen.show(context, widget.images, initialIndex: _index);
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMany = widget.images.length > 1;
    return GestureDetector(
      onTap: _open,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: ColoredBox(
          color: Colors.black26,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasMany)
                NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: PageView.builder(
                    controller: _pages,
                    physics: const ClampingScrollPhysics(),
                    itemCount: widget.images.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (_, index) => MindImageView(image: widget.images[index], cacheWidth: 1200),
                  ),
                )
              else
                MindImageView(image: widget.images.first, cacheWidth: 1200),
              if (hasMany)
                Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 10.0,
                  child: _Dots(count: widget.images.length, index: _index),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (int i = 0; i < count; i++)
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3.0),
          width: 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == index ? Colors.white : Colors.white54,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4.0)],
          ),
        ),
    ],
  );
}

/// Up to four tiles, the last one showing how many more there are; a tap opens them full-screen.
final class MindImageGrid extends StatelessWidget {
  static const int _maxTiles = 4;
  static const double _gap = 2.0;

  final List<MindNoteImage> images;
  final double width;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  const MindImageGrid({super.key, required this.images, required this.width, this.onOpen, this.onClose});

  Future<void> _open(BuildContext context, int index) async {
    onOpen?.call();
    await MindImagesFullscreen.show(context, images, initialIndex: index);
    onClose?.call();
  }

  Widget _tile(BuildContext context, int index, {required double width, required double height}) {
    final int hidden = images.length - _maxTiles;
    final bool showsMore = index == _maxTiles - 1 && hidden > 0;
    return GestureDetector(
      onTap: () => _open(context, index),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MindImageView(image: images[index], cacheWidth: (width * 3).round()),
            if (showsMore)
              ColoredBox(
                color: Colors.black45,
                child: Center(
                  child: Text(
                    '+${hidden + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double half = (width - _gap) / 2;
    final Widget grid = switch (images.length) {
      1 => _tile(context, 0, width: width, height: width),
      2 => Row(
        spacing: _gap,
        children: [
          _tile(context, 0, width: half, height: width),
          _tile(context, 1, width: half, height: width),
        ],
      ),
      3 => Row(
        spacing: _gap,
        children: [
          _tile(context, 0, width: half, height: width),
          Column(
            spacing: _gap,
            children: [
              _tile(context, 1, width: half, height: half),
              _tile(context, 2, width: half, height: half),
            ],
          ),
        ],
      ),
      _ => Column(
        spacing: _gap,
        children: [
          for (int row = 0; row < 2; row++)
            Row(
              spacing: _gap,
              children: [
                for (int column = 0; column < 2; column++) _tile(context, row * 2 + column, width: half, height: half),
              ],
            ),
        ],
      ),
    };
    return ClipRRect(borderRadius: BorderRadius.circular(16.0), child: grid);
  }
}

/// Picked images above a text field: drag to reorder, ✕ to remove.
final class MindImageStrip extends StatelessWidget {
  static const double height = 88.0;

  final List<MindNoteImage> images;
  final ValueChanged<List<MindNoteImage>> onChanged;
  final EdgeInsets padding;

  const MindImageStrip({
    super.key,
    required this.images,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
  });

  void _reorder(int from, int to) {
    final List<MindNoteImage> reordered = List.of(images);
    final MindNoteImage moved = reordered.removeAt(from);
    reordered.insert(to, moved);
    onChanged(reordered);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: ReorderableListView.builder(
      scrollDirection: Axis.horizontal,
      padding: padding,
      buildDefaultDragHandles: false,
      proxyDecorator: (child, _, _) => Material(color: Colors.transparent, child: child),
      itemCount: images.length,
      onReorderItem: _reorder,
      itemBuilder: (context, index) {
        final MindNoteImage image = images[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey(image.appRelativePath),
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox.square(
              dimension: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () => MindImagesFullscreen.show(context, images, initialIndex: index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: MindImageView(image: image, cacheWidth: 300),
                    ),
                  ),
                  Positioned(
                    top: 4.0,
                    right: 4.0,
                    child: GestureDetector(
                      onTap: () => onChanged(List.of(images)..removeAt(index)),
                      child: Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 14.0, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// "🖼 3" next to the time of a mind with images.
final class MindImageBadge extends StatelessWidget {
  final int count;
  final Color color;
  final double size;

  const MindImageBadge({super.key, required this.count, required this.color, this.size = 13.0});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 3.0,
    children: [
      Icon(Icons.photo_outlined, size: size + 2.0, color: color),
      Text(
        '$count',
        style: TextStyle(fontSize: size, color: color),
      ),
    ],
  );
}
