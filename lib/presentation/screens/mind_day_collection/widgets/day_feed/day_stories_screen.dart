import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_story_details.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:keklist/native/android/media_folder_channel.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/folder_media_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/core/shake/shake_to_tweak_mixin.dart';
import 'package:keklist/presentation/core/widgets/round_video/round_video_views.dart';
import 'package:keklist/presentation/core/widgets/sound/animated_emotion_texture.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_playback.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_spectrum_ring.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_audio_circle.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_item_viewer_screen.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/story_texture_tweak_sheet.dart';
import 'package:keklist/presentation/core/helpers/media_sources.dart';
import 'package:keklist/presentation/core/widgets/gallery/gallery_media.dart';

const double _kDismissDragDistance = 120.0;
const double _kDismissDragVelocity = 700.0;
const double _kOpenMindDragDistance = -80.0;
const Duration _kVideoFallbackDuration = Duration(seconds: 5);
const double _kStoryRoundVideoSize = 280.0;
const double _kStoryAudioCircleSize = 220.0;
const double _kFadeDistance = 320.0;
const double _kHeaderSpace = 96.0;
const double _kWideStoriesMinWidth = 800.0;

final class DayStoriesScreen extends StatefulWidget {
  final List<DayFeedItem> items;
  final int initialIndex;
  const DayStoriesScreen({super.key, required this.items, required this.initialIndex});

  @override
  State<DayStoriesScreen> createState() => _DayStoriesScreenState();
}

final class _DayStoriesScreenState extends State<DayStoriesScreen>
    with SingleTickerProviderStateMixin, ShakeToTweakMixin {
  // Remembered for the app session, like Instagram.
  static bool _isMutedForSession = true;

  late int _index = widget.initialIndex;
  late final AnimationController _progress = AnimationController(vsync: this)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) _goNext();
    });
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  StreamSubscription<double>? _volumeSubscription;
  bool _isPaused = false;
  double _dragOffsetY = 0.0;
  final ValueNotifier<SoundPlayback?> _sound = ValueNotifier(null);

  @override
  String get shakeScreenId => ShakeScreenIds.story;

  @override
  Future<void> onShakeToTweak() async {
    _pause();
    await StoryTextureTweakSheet.show(context);
    if (mounted) _resume();
  }

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
    _audioPlayer?.dispose();
    _progress.dispose();
    _sound.dispose();
    super.dispose();
  }

  void _listenToVolumeButtons() {
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) return;
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
    _sound.value = null;
    await _disposeVideo();
    await _disposeAudio();

    final DayFeedItem item = _currentItem;
    switch (item) {
      case DayFeedMind(:final mind) when mind.noteContent.hasVideo:
        await _playVideo(item);
      case DayFeedMind(:final mind) when mind.noteContent.hasAudio:
        await _playAudio(mind.noteContent.audioPieces.first, fallback: DayFeedLayout.mindStoryDuration(mind));
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
    final String? soundPath = await _mindVideoPath(item);
    if (soundPath != null && mounted && requestedIndex == _index) {
      _sound.value = SoundPlayback.video(controller).withEnvelopeOf(soundPath);
    }
    final Duration duration = controller.value.duration;
    _startProgress(duration > Duration.zero ? duration : _kVideoFallbackDuration);
    if (!_isPaused) await controller.play();
  }

  Future<VideoPlayerController?> _createVideoController(DayFeedItem item) async {
    switch (item) {
      case DayFeedAsset(:final asset):
        return GalleryMedia.videoController(asset);
      case DayFeedFolderMedia(item: FolderFileItem(:final file)):
        return VideoPlayerController.file(file);
      case DayFeedFolderMedia(item: FolderSafItem(:final uri)):
        return VideoPlayerController.contentUri(uri);
      case DayFeedMind():
        final String? path = await _mindVideoPath(item);
        return path == null ? null : videoControllerFor(path);
    }
  }

  Future<String?> _mindVideoPath(DayFeedItem item) async {
    if (item is! DayFeedMind) return null;
    final MindNoteVideo? video = item.mind.noteContent.videoPieces.firstOrNull;
    if (video == null) return null;
    return context.read<AppFileRepository>().resolveAbsolutePath(video.appRelativePath);
  }

  Future<void> _playAudio(MindNoteAudio audio, {required Duration fallback}) async {
    final int requestedIndex = _index;
    final String path = await context.read<AppFileRepository>().resolveAbsolutePath(audio.appRelativeAbsoulutePath);
    final AudioPlayer player = AudioPlayer();
    final Duration? loadedDuration = await setAudioSource(player, path).catchError((_) => null);
    if (!mounted || requestedIndex != _index) {
      await player.dispose();
      return;
    }
    await player.setVolume(_isMutedForSession ? 0.0 : 1.0);
    setState(() => _audioPlayer = player);
    _sound.value = SoundPlayback.audio(player).withEnvelopeOf(path);
    final Duration duration = loadedDuration ?? audio.duration ?? fallback;
    _startProgress(duration > Duration.zero ? duration : fallback);
    if (!_isPaused) unawaited(player.play());
  }

  Future<void> _disposeAudio() async {
    final AudioPlayer? player = _audioPlayer;
    _audioPlayer = null;
    await player?.dispose();
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
    _audioPlayer?.pause();
  }

  void _resume() {
    _isPaused = false;
    if (_progress.duration != null) _progress.forward();
    _videoController?.play();
    _audioPlayer?.play();
  }

  void _setMuted(bool isMuted) {
    if (!mounted) return;
    _isMutedForSession = isMuted;
    _videoController?.setVolume(isMuted ? 0.0 : 1.0);
    _audioPlayer?.setVolume(isMuted ? 0.0 : 1.0);
    setState(() {});
  }

  Future<void> _openInViewer() async {
    _pause();
    await DayItemViewerScreen.show(context, items: widget.items, initialIndex: _index);
    if (mounted) _resume();
  }

  void _onTapUp(TapUpDetails details, double width) {
    final double x = details.localPosition.dx;
    if (x < width / 3) {
      _goPrevious();
      return;
    }
    final DayFeedItem item = _currentItem;
    if (x < width * 2 / 3 && item is DayFeedMind) {
      _openInViewer();
      return;
    }
    _goNext();
  }

  void _togglePause() => _isPaused ? _resume() : _pause();

  void _onVerticalDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0.0;
    final DayFeedItem item = _currentItem;
    if (_dragOffsetY > _kDismissDragDistance || velocity > _kDismissDragVelocity) {
      Navigator.of(context).pop();
      return;
    }
    if (_dragOffsetY < _kOpenMindDragDistance && item is DayFeedMind) _openInViewer();
    setState(() => _dragOffsetY = 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final double dismissProgress = (_dragOffsetY.clamp(0.0, _kFadeDistance)) / _kFadeDistance;
    final Size screen = MediaQuery.sizeOf(context);
    final bool isWide = screen.width >= _kWideStoriesMinWidth;
    final Widget story = LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => _onTapUp(details, constraints.maxWidth),
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        onVerticalDragUpdate: (details) => setState(() => _dragOffsetY += details.delta.dy),
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Opacity(
          opacity: 1.0 - dismissProgress * 0.85,
          child: Transform.translate(
            offset: Offset(0.0, _dragOffsetY.clamp(0.0, double.infinity)),
            // Content fills the story so a mind's texture runs behind the progress bars and the header.
            child: Stack(
              children: [
                Positioned.fill(child: _buildContent(context)),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: SafeArea(
                    bottom: false,
                    child: Column(children: [_buildProgressBars(), _buildHeader(context)]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _goPrevious,
        const SingleActivator(LogicalKeyboardKey.arrowRight): _goNext,
        const SingleActivator(LogicalKeyboardKey.space): _togglePause,
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(),
      },
      child: Focus(
        autofocus: true,
        child: isWide
            ? _buildWide(context, story, screen, dismissProgress)
            : Scaffold(
                backgroundColor: storyColorsOf(context).background.withValues(alpha: 1.0 - dismissProgress),
                body: story,
              ),
      ),
    );
  }

  /// On a desktop the story is a phone-shaped card in the middle, like Instagram on the web.
  Widget _buildWide(BuildContext context, Widget story, Size screen, double dismissProgress) {
    final double height = screen.height - 32.0;
    final double width = height * 9.0 / 16.0;
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.9 * (1.0 - dismissProgress)),
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).pop()),
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 16.0,
              children: [
                _arrow(Icons.chevron_left_rounded, _index > 0 ? _goPrevious : null),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: ColoredBox(
                    color: storyColorsOf(context).background,
                    child: SizedBox(width: width, height: height, child: story),
                  ),
                ),
                _arrow(Icons.chevron_right_rounded, _goNext),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrow(IconData icon, VoidCallback? onPressed) => IconButton.filled(
    style: IconButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white),
    icon: Icon(icon),
    onPressed: onPressed,
  );

  Widget _buildProgressBars() {
    final Color foreground = storyColorsOf(context).foreground;
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
                    backgroundColor: foreground.withValues(alpha: 0.25),
                    valueColor: AlwaysStoppedAnimation<Color>(foreground),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final DayFeedItem item = _currentItem;
    final bool isVideo =
        (item is DayFeedAsset && item.isVideo) ||
        (item is DayFeedFolderMedia && item.isVideo) ||
        (item is DayFeedMind && item.mind.noteContent.hasMedia);
    final Color foreground = storyColorsOf(context).foreground;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            // Symmetric so the pill stays centered past the buttons on the right.
            padding: EdgeInsets.symmetric(horizontal: (isVideo ? 2 : 1) * 48.0 + 4.0),
            child: StoryDateHeader(date: item.timestamp),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isVideo)
                  IconButton(
                    color: foreground,
                    tooltip: _isMutedForSession ? context.l10n.dayFeedUnmute : context.l10n.dayFeedMute,
                    icon: Icon(_isMutedForSession ? Icons.volume_off : Icons.volume_up),
                    onPressed: () => _setMuted(!_isMutedForSession),
                  ),
                IconButton(
                  color: foreground,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final DayFeedItem item = _currentItem;
    final VideoPlayerController? video = _videoController;
    if (item is DayFeedMind) {
      return SoundPlaybackScope(
        notifier: _sound,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedEmotionTexture(mind: item.mind, color: storyColorsOf(context).foreground),
            _MindStory(item: item, roundVideo: video, audioPlayer: _audioPlayer),
          ],
        ),
      );
    }
    if (video != null && video.value.isInitialized) {
      return Center(
        child: AspectRatio(aspectRatio: video.value.aspectRatio, child: VideoPlayer(video)),
      );
    }
    return switch (item) {
      DayFeedMind() => _MindStory(item: item),
      DayFeedAsset(isVideo: true) || DayFeedFolderMedia(isVideo: true) => const _Loading(),
      DayFeedAsset(:final asset) => Stack(
        key: ValueKey(item.id),
        fit: StackFit.expand,
        children: [
          Image(
            image: GalleryMedia.thumbnail(asset),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const _Loading(),
          ),
          Image(
            image: GalleryMedia.original(asset),
            fit: BoxFit.contain,
            frameBuilder: (_, child, frame, wasSynchronouslyLoaded) => AnimatedOpacity(
              opacity: frame == null && !wasSynchronouslyLoaded ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: child,
            ),
          ),
        ],
      ),
      DayFeedFolderMedia(item: FolderFileItem(:final file)) => Image.file(
        file,
        key: ValueKey(item.id),
        fit: BoxFit.contain,
      ),
      DayFeedFolderMedia(item: final FolderSafItem safItem) => _SafPhoto(key: ValueKey(item.id), item: safItem),
    };
  }
}

final class _MindStory extends StatelessWidget {
  final DayFeedMind item;
  final VideoPlayerController? roundVideo;
  final AudioPlayer? audioPlayer;

  const _MindStory({required this.item, this.roundVideo, this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? video = roundVideo;
    final MindNoteAudio? audio = item.mind.noteContent.audioPieces.firstOrNull;
    final AudioPlayer? player = audioPlayer;
    final Color accent = mindAccentColorOf(context, item.mind);
    final EdgeInsets safe = MediaQuery.paddingOf(context);
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.0, safe.top + _kHeaderSpace, 24.0, safe.bottom + 24.0),
        child: MindStoryDetails(
          mind: item.mind,
          media: item.mind.noteContent.hasVideo
              ? SoundSpectrumRing(
                  diameter: _kStoryRoundVideoSize,
                  color: accent,
                  child: video != null && video.value.isInitialized
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            RoundVideoSurface(controller: video),
                            RoundVideoProgressRing(controller: video),
                          ],
                        )
                      : const _Loading(),
                )
              : audio != null && player != null
              ? MindAudioCircle(audio: audio, color: accent, diameter: _kStoryAudioCircleSize, player: player)
              : null,
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
