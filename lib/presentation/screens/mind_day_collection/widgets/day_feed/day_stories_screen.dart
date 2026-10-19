import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:intl/intl.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/native/android/media_folder_channel.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/date_gallery/folder_media_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:video_player/video_player.dart';

const double _kDismissDragDistance = 120.0;
const double _kDismissDragVelocity = 700.0;
const double _kOpenMindDragDistance = -80.0;
const Duration _kVideoFallbackDuration = Duration(seconds: 5);

final class DayStoriesScreen extends StatefulWidget {
  final List<DayFeedItem> items;
  final int initialIndex;
  final bool isMindTextHidden;
  final Future<void> Function(Mind mind) onOpenMind;

  const DayStoriesScreen({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.isMindTextHidden,
    required this.onOpenMind,
  });

  @override
  State<DayStoriesScreen> createState() => _DayStoriesScreenState();
}

final class _DayStoriesScreenState extends State<DayStoriesScreen> with SingleTickerProviderStateMixin {
  // Remembered for the app session, like Instagram.
  static bool _isMutedForSession = true;

  late int _index = widget.initialIndex;
  late final AnimationController _progress = AnimationController(vsync: this)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) _goNext();
    });
  VideoPlayerController? _videoController;
  StreamSubscription<double>? _volumeSubscription;
  bool _isPaused = false;
  double _dragOffsetY = 0.0;

  DayFeedItem get _currentItem => widget.items[_index];

  @override
  void initState() {
    super.initState();
    _listenToVolumeButtons();
    _showCurrentItem();
  }

  @override
  void dispose() {
    _volumeSubscription?.cancel();
    FlutterVolumeController.removeListener();
    _videoController?.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _listenToVolumeButtons() {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    _volumeSubscription = FlutterVolumeController.addListener(
      (_) => _setMuted(false),
      category: AudioSessionCategory.playback,
      emitOnStart: false,
    );
  }

  Future<void> _showCurrentItem() async {
    _progress
      ..stop()
      ..value = 0.0;
    await _disposeVideo();

    final DayFeedItem item = _currentItem;
    switch (item) {
      case DayFeedMind(:final mind):
        _startProgress(DayFeedLayout.mindStoryDuration(mind));
      case DayFeedAsset(isVideo: true):
      case DayFeedFolderMedia(isVideo: true):
        await _playVideo(item);
      case DayFeedAsset():
      case DayFeedFolderMedia():
        _startProgress(DayFeedLayout.photoStoryDuration);
    }
  }

  Future<void> _playVideo(DayFeedItem item) async {
    final int requestedIndex = _index;
    final VideoPlayerController? controller = await _createVideoController(item);
    if (!mounted || requestedIndex != _index) {
      await controller?.dispose();
      return;
    }
    if (controller == null) {
      _startProgress(_kVideoFallbackDuration);
      return;
    }
    await controller.initialize();
    if (!mounted || requestedIndex != _index) {
      await controller.dispose();
      return;
    }
    await controller.setVolume(_isMutedForSession ? 0.0 : 1.0);
    setState(() => _videoController = controller);
    final Duration duration = controller.value.duration;
    _startProgress(duration > Duration.zero ? duration : _kVideoFallbackDuration);
    if (!_isPaused) await controller.play();
  }

  Future<VideoPlayerController?> _createVideoController(DayFeedItem item) async {
    switch (item) {
      case DayFeedAsset(:final asset):
        final File? file = await asset.file;
        return file == null ? null : VideoPlayerController.file(file);
      case DayFeedFolderMedia(item: FolderFileItem(:final file)):
        return VideoPlayerController.file(file);
      case DayFeedFolderMedia(item: FolderSafItem(:final uri)):
        return VideoPlayerController.contentUri(uri);
      case DayFeedMind():
        return null;
    }
  }

  Future<void> _disposeVideo() async {
    final VideoPlayerController? controller = _videoController;
    if (controller == null) return;
    setState(() => _videoController = null);
    await controller.dispose();
  }

  void _startProgress(Duration duration) {
    _progress.duration = duration;
    if (!_isPaused) _progress.forward(from: 0.0);
  }

  void _goNext() {
    if (_index >= widget.items.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _index++);
    _showCurrentItem();
  }

  void _goPrevious() {
    if (_index > 0) setState(() => _index--);
    _showCurrentItem();
  }

  void _pause() {
    _isPaused = true;
    _progress.stop();
    _videoController?.pause();
  }

  void _resume() {
    _isPaused = false;
    if (_progress.duration != null) _progress.forward();
    _videoController?.play();
  }

  void _setMuted(bool isMuted) {
    if (!mounted) return;
    _isMutedForSession = isMuted;
    _videoController?.setVolume(isMuted ? 0.0 : 1.0);
    setState(() {});
  }

  Future<void> _openMind(Mind mind) async {
    _pause();
    await widget.onOpenMind(mind);
    if (mounted) _resume();
  }

  void _onTapUp(TapUpDetails details) {
    final double width = MediaQuery.sizeOf(context).width;
    final double x = details.globalPosition.dx;
    if (x < width / 3) {
      _goPrevious();
      return;
    }
    final DayFeedItem item = _currentItem;
    if (x < width * 2 / 3 && item is DayFeedMind) {
      _openMind(item.mind);
      return;
    }
    _goNext();
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0.0;
    final DayFeedItem item = _currentItem;
    if (_dragOffsetY > _kDismissDragDistance || velocity > _kDismissDragVelocity) {
      Navigator.of(context).pop();
      return;
    }
    if (_dragOffsetY < _kOpenMindDragDistance && item is DayFeedMind) _openMind(item.mind);
    setState(() => _dragOffsetY = 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final double dismissProgress = (_dragOffsetY.clamp(0.0, 350.0)) / 350.0;
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 1.0 - dismissProgress),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: _onTapUp,
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        onVerticalDragUpdate: (details) => setState(() => _dragOffsetY += details.delta.dy),
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Transform.translate(
          offset: Offset(0.0, _dragOffsetY.clamp(0.0, double.infinity)),
          child: SafeArea(
            child: Column(
              children: [
                _buildProgressBars(),
                _buildHeader(context),
                Expanded(child: _buildContent(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBars() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, _) => Row(
          spacing: 3.0,
          children: [
            for (int index = 0; index < widget.items.length; index++)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.0),
                  child: LinearProgressIndicator(
                    minHeight: 2.5,
                    value: index < _index ? 1.0 : (index == _index ? _progress.value : 0.0),
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final String time = DateFormat.Hm(Localizations.localeOf(context).toString()).format(_currentItem.timestamp.toLocal());
    final DayFeedItem item = _currentItem;
    final bool isVideo = (item is DayFeedAsset && item.isVideo) || (item is DayFeedFolderMedia && item.isVideo);
    return Row(
      children: [
        const SizedBox(width: 16.0),
        Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const Spacer(),
        if (isVideo)
          IconButton(
            color: Colors.white,
            tooltip: _isMutedForSession ? context.l10n.dayFeedUnmute : context.l10n.dayFeedMute,
            icon: Icon(_isMutedForSession ? Icons.volume_off : Icons.volume_up),
            onPressed: () => _setMuted(!_isMutedForSession),
          ),
        IconButton(color: Colors.white, icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final DayFeedItem item = _currentItem;
    final VideoPlayerController? video = _videoController;
    if (video != null && video.value.isInitialized) {
      return Center(child: AspectRatio(aspectRatio: video.value.aspectRatio, child: VideoPlayer(video)));
    }
    return switch (item) {
      DayFeedMind() => _MindStory(item: item, isTextHidden: widget.isMindTextHidden),
      DayFeedAsset(isVideo: true) || DayFeedFolderMedia(isVideo: true) => const _Loading(),
      DayFeedAsset(:final asset) => Image(
          key: ValueKey(item.id),
          image: AssetEntityImageProvider(asset, isOriginal: true),
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) => progress == null ? child : const _Loading(),
        ),
      DayFeedFolderMedia(item: FolderFileItem(:final file)) => Image.file(file, key: ValueKey(item.id), fit: BoxFit.contain),
      DayFeedFolderMedia(item: final FolderSafItem safItem) => _SafPhoto(key: ValueKey(item.id), item: safItem),
    };
  }
}

final class _MindStory extends StatelessWidget {
  final DayFeedMind item;
  final bool isTextHidden;

  const _MindStory({required this.item, required this.isTextHidden});

  @override
  Widget build(BuildContext context) {
    final String text = item.mind.plainNote.trim();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.mind.emoji, style: const TextStyle(fontSize: 96.0)),
            if (!isTextHidden && text.isNotEmpty) ...[
              const SizedBox(height: 24.0),
              Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20.0)),
            ],
            if (item.mind.audioNotes.isNotEmpty || item.reflectionCount > 0) ...[
              const SizedBox(height: 16.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 12.0,
                children: [
                  if (item.mind.audioNotes.isNotEmpty) const Icon(Icons.mic, color: Colors.white70),
                  if (item.reflectionCount > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4.0,
                      children: [
                        const Icon(Icons.forum_outlined, color: Colors.white70, size: 20.0),
                        Text('${item.reflectionCount}', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _SafPhoto extends StatefulWidget {
  final FolderSafItem item;

  const _SafPhoto({super.key, required this.item});

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
        if (bytes != null) return Image.memory(bytes, fit: BoxFit.contain);
        if (snapshot.connectionState == ConnectionState.done) {
          return const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48));
        }
        return const _Loading();
      },
    );
  }
}

final class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator(color: Colors.white));
}
