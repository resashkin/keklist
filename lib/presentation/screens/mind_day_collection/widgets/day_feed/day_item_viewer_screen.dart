import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/native/android/media_folder_channel.dart';
import 'package:keklist/presentation/core/widgets/gallery/cached_asset_thumbnail_provider.dart';
import 'package:keklist/presentation/core/widgets/round_video/round_video_views.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/folder_media_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_story_details.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:video_player/video_player.dart';

const double _kDismissDragDistance = 120.0;
const double _kDismissDragVelocity = 700.0;
const double _kRoundVideoSize = 260.0;

/// A calm look at one tile at a time: swipe between the day's items, no progress bars, no timer.
/// Swipe down (or ✕) closes it; a mind can be opened in full from the header.
final class DayItemViewerScreen extends StatefulWidget {
  final List<DayFeedItem> items;
  final int initialIndex;
  final Future<void> Function(Mind mind) onOpenMind;

  const DayItemViewerScreen({super.key, required this.items, required this.initialIndex, required this.onOpenMind});

  /// Pushed over the current screen with a fade, like the stories.
  static Future<void> show(
    BuildContext context, {
    required List<DayFeedItem> items,
    required int initialIndex,
    required Future<void> Function(Mind mind) onOpenMind,
  }) {
    if (items.isEmpty) return Future.value();
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        fullscreenDialog: true,
        pageBuilder: (_, _, _) => DayItemViewerScreen(
          items: items,
          initialIndex: initialIndex.clamp(0, items.length - 1),
          onOpenMind: onOpenMind,
        ),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<DayItemViewerScreen> createState() => _DayItemViewerScreenState();
}

final class _DayItemViewerScreenState extends State<DayItemViewerScreen> {
  late final PageController _pageController = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  double _dragOffsetY = 0.0;

  DayFeedItem get _currentItem => widget.items[_index];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (:background, :foreground) = storyColorsOf(context);
    final double dismissProgress = _dragOffsetY.clamp(0.0, 350.0) / 350.0;
    return Scaffold(
      backgroundColor: background.withValues(alpha: 1.0 - dismissProgress),
      body: NotificationListener<OverscrollNotification>(
        onNotification: _onOverscroll,
        child: GestureDetector(
          onVerticalDragUpdate: (details) => setState(() => _dragOffsetY = (_dragOffsetY + details.delta.dy).clamp(0.0, double.infinity)),
          onVerticalDragEnd: _onVerticalDragEnd,
          child: Transform.translate(
            offset: Offset(0.0, _dragOffsetY),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, foreground),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.items.length,
                      onPageChanged: (index) => setState(() => _index = index),
                      itemBuilder: (context, index) => _ViewerPage(
                        key: ValueKey(widget.items[index].id),
                        item: widget.items[index],
                        isCurrent: index == _index,
                      ),
                    ),
                  ),
                  if (widget.items.length > 1) _buildPageDots(foreground),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color foreground) {
    final String locale = Localizations.localeOf(context).toString();
    final DayFeedItem item = _currentItem;
    final String date = DateFormat.yMMMMd(locale).add_Hm().format(item.timestamp.toLocal());
    return Row(
      children: [
        const SizedBox(width: 16.0),
        Expanded(
          child: Text(date, style: TextStyle(color: foreground, fontWeight: FontWeight.w600)),
        ),
        if (item is DayFeedMind)
          IconButton(
            color: foreground,
            icon: const Icon(Icons.open_in_full_rounded),
            onPressed: () => widget.onOpenMind(item.mind),
          ),
        IconButton(color: foreground, icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }

  Widget _buildPageDots(Color foreground) {
    const int maxDots = 12;
    final int count = widget.items.length;
    if (count > maxDots) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text('${_index + 1} / $count', style: TextStyle(color: foreground.withValues(alpha: 0.6))),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 6.0,
        children: [
          for (int index = 0; index < count; index++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: index == _index ? 16.0 : 6.0,
              height: 6.0,
              decoration: BoxDecoration(
                color: foreground.withValues(alpha: index == _index ? 0.9 : 0.3),
                borderRadius: BorderRadius.circular(3.0),
              ),
            ),
        ],
      ),
    );
  }

  bool _onOverscroll(OverscrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical &&
        notification.overscroll < 0 &&
        notification.dragDetails != null &&
        notification.overscroll.abs() > 12.0) {
      Navigator.of(context).maybePop();
    }
    return false;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffsetY > _kDismissDragDistance || (details.primaryVelocity ?? 0.0) > _kDismissDragVelocity) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _dragOffsetY = 0.0);
  }
}

final class _ViewerPage extends StatelessWidget {
  final DayFeedItem item;
  final bool isCurrent;

  const _ViewerPage({super.key, required this.item, required this.isCurrent});

  @override
  Widget build(BuildContext context) => switch (item) {
    DayFeedMind(:final mind) => _MindPage(mind: mind, isCurrent: isCurrent),
    DayFeedAsset(isVideo: true) || DayFeedFolderMedia(isVideo: true) => _VideoPage(item: item, isCurrent: isCurrent),
    DayFeedAsset(:final asset) => InteractiveViewer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(image: CachedAssetThumbnailProvider(asset), fit: BoxFit.contain, errorBuilder: (_, _, _) => const _Loading()),
          Image(
            image: AssetEntityImageProvider(asset, isOriginal: true),
            fit: BoxFit.contain,
            frameBuilder: (_, child, frame, wasSynchronouslyLoaded) => AnimatedOpacity(
              opacity: frame == null && !wasSynchronouslyLoaded ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: child,
            ),
          ),
        ],
      ),
    ),
    DayFeedFolderMedia(item: FolderFileItem(:final file)) => InteractiveViewer(child: Image.file(file, fit: BoxFit.contain)),
    DayFeedFolderMedia(item: final FolderSafItem safItem) => _SafPhoto(item: safItem),
  };
}

final class _MindPage extends StatelessWidget {
  final Mind mind;
  final bool isCurrent;

  const _MindPage({required this.mind, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final MindNoteVideo? video = mind.noteContent.videoPieces.firstOrNull;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 48.0),
          child: Center(
            child: MindStoryDetails(
              mind: mind,
              showsAudioPlayer: true,
              media: video == null ? null : _RoundVideoPlayer(video: video, isCurrent: isCurrent),
            ),
          ),
        ),
      ),
    );
  }
}

/// Plays while its page is current; a tap pauses or resumes.
final class _RoundVideoPlayer extends StatefulWidget {
  final MindNoteVideo video;
  final bool isCurrent;

  const _RoundVideoPlayer({required this.video, required this.isCurrent});

  @override
  State<_RoundVideoPlayer> createState() => _RoundVideoPlayerState();
}

final class _RoundVideoPlayerState extends State<_RoundVideoPlayer> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final String path = await context.read<AppFileRepository>().resolveAbsolutePath(widget.video.appRelativePath);
    final VideoPlayerController controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
    if (widget.isCurrent) unawaited(controller.play());
  }

  @override
  void didUpdateWidget(_RoundVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isCurrent) _controller?.pause();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;
    return SizedBox.square(
      dimension: _kRoundVideoSize,
      child: controller == null
          ? const _Loading()
          : GestureDetector(
              onTap: () => setState(() => controller.value.isPlaying ? controller.pause() : controller.play()),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RoundVideoSurface(controller: controller),
                  RoundVideoProgressRing(controller: controller),
                  ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: controller,
                    builder: (_, value, _) => value.isPlaying ? const SizedBox.shrink() : const _PlayBadge(),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Library and folder videos: plays while its page is current, loops, a tap pauses or resumes.
final class _VideoPage extends StatefulWidget {
  final DayFeedItem item;
  final bool isCurrent;

  const _VideoPage({required this.item, required this.isCurrent});

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

final class _VideoPageState extends State<_VideoPage> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final VideoPlayerController? controller = switch (widget.item) {
      DayFeedAsset(:final asset) => await asset.file.then((file) => file == null ? null : VideoPlayerController.file(file)),
      DayFeedFolderMedia(item: FolderFileItem(:final file)) => VideoPlayerController.file(file),
      DayFeedFolderMedia(item: FolderSafItem(:final uri)) => VideoPlayerController.contentUri(uri),
      _ => null,
    };
    if (controller == null) return;
    await controller.initialize();
    await controller.setLooping(true);
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
    if (widget.isCurrent) unawaited(controller.play());
  }

  @override
  void didUpdateWidget(_VideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isCurrent) _controller?.pause();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;
    if (controller == null) return const _Loading();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => controller.value.isPlaying ? controller.pause() : controller.play()),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller)),
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller,
            builder: (_, value, _) => value.isPlaying ? const SizedBox.shrink() : const _PlayBadge(),
          ),
        ],
      ),
    );
  }
}

final class _PlayBadge extends StatelessWidget {
  const _PlayBadge();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40.0),
    ),
  );
}

final class _SafPhoto extends StatefulWidget {
  final FolderSafItem item;

  const _SafPhoto({required this.item});

  @override
  State<_SafPhoto> createState() => _SafPhotoState();
}

final class _SafPhotoState extends State<_SafPhoto> {
  late final Future<Uint8List?> _bytes = MediaFolderChannel.getDocumentContent(widget.item.uri.toString());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _bytes,
      builder: (context, snapshot) {
        final Uint8List? bytes = snapshot.data;
        if (bytes != null) return InteractiveViewer(child: Image.memory(bytes, fit: BoxFit.contain));
        if (snapshot.connectionState == ConnectionState.done) {
          return Center(child: Icon(Icons.broken_image_outlined, color: storyColorsOf(context).foreground, size: 48));
        }
        return const _Loading();
      },
    );
  }
}

final class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) =>
      Center(child: CircularProgressIndicator(color: storyColorsOf(context).foreground));
}
