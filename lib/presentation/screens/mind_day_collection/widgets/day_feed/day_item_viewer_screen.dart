import 'dart:async';
import 'dart:math' as math;

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/debug_menu/debug_menu_repository.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/native/android/media_folder_channel.dart';
import 'package:keklist/presentation/blocs/debug_menu_bloc/debug_menu_bloc.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/shake/shake_to_tweak_mixin.dart';
import 'package:keklist/presentation/core/widgets/round_video/round_video_views.dart';
import 'package:keklist/presentation/core/widgets/sound/animated_emotion_texture.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_playback.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_spectrum_ring.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_audio_circle.dart';
import 'package:keklist/presentation/screens/emotions/emotion_marking_sheet.dart';
import 'package:keklist/presentation/screens/mind_creator/mind_creator_screen.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/folder_media_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_comments.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_story_details.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/story_texture_tweak_sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:native_liquid_glass/native_liquid_glass.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:translator/translator.dart';
import 'package:video_player/video_player.dart';
import 'package:keklist/presentation/core/helpers/media_sources.dart';
import 'package:keklist/presentation/core/helpers/mind_text_edit.dart';
import 'package:keklist/presentation/core/widgets/gallery/gallery_media.dart';

const double _kDismissDragDistance = 120.0;
const double _kDismissDragVelocity = 700.0;
const double _kDismissOverscroll = 80.0;
const double _kRoundVideoSize = 260.0;
const double _kAudioCircleSize = 200.0;
const double _kFadeDistance = 320.0;
const double _kHeaderSpace = 100.0;
const double _kEdgeTapShare = 0.22;
const Duration _kVideoFallbackDuration = Duration(seconds: 5);
const double _kWideMinWidth = 800.0;

/// The day's items as stories: segments on top, a tap on an edge or a swipe moves between them. Opened from a tile it
/// stands still; with [autoplay] (▶ on a day or a week) a timer moves on and holding pauses it.
/// Minds are edited right here: long-press the text to edit it, comment below, ⋯ or a long-pressed comment for the rest.
/// Swipe down or ✕ closes it.
final class DayItemViewerScreen extends StatefulWidget {
  final List<DayFeedItem> items;
  final int initialIndex;
  final bool autoplay;

  const DayItemViewerScreen({super.key, required this.items, required this.initialIndex, this.autoplay = false});

  /// Pushed over the current screen with a fade.
  static Future<void> show(
    BuildContext context, {
    required List<DayFeedItem> items,
    required int initialIndex,
    bool autoplay = false,
  }) {
    if (items.isEmpty) return Future.value();
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        fullscreenDialog: true,
        pageBuilder: (_, _, _) => DayItemViewerScreen(
          items: items,
          initialIndex: initialIndex.clamp(0, items.length - 1),
          autoplay: autoplay,
        ),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  /// A single mind, e.g. from search or the digest.
  static Future<void> showMind(BuildContext context, Mind mind) =>
      show(context, items: [DayFeedMind(mind: mind)], initialIndex: 0);

  @override
  State<DayItemViewerScreen> createState() => _DayItemViewerScreenState();
}

final class _DayItemViewerScreenState extends State<DayItemViewerScreen>
    with ShakeToTweakMixin, SingleTickerProviderStateMixin {
  late final PageController _pageController = PageController(initialPage: widget.initialIndex);
  late final AnimationController _progress = AnimationController(vsync: this)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) _goNext();
    });
  late int _index = widget.initialIndex;
  double _dragOffsetY = 0.0;
  double _scrollPull = 0.0;
  bool _isClosing = false;
  bool _isHeld = false;


  DayFeedItem get _currentItem => widget.items[_index];

  @override
  String get shakeScreenId => ShakeScreenIds.story;

  @override
  Future<void> onShakeToTweak() => _whileHeld(() => StoryTextureTweakSheet.show(context));

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _progress.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Mind? _liveMind(String id) {
    final MindState state = context.read<MindBloc>().state;
    return state is MindList ? state.values.firstWhereOrNull((mind) => mind.id == id) : null;
  }

  // The timer of ▶

  Duration _durationOf(DayFeedItem item) => switch (item) {
    DayFeedMind(:final mind) when mind.noteContent.hasVideo => _kVideoFallbackDuration,
    DayFeedMind(:final mind) =>
      mind.noteContent.audioPieces.firstOrNull?.duration ?? DayFeedLayout.mindStoryDuration(mind),
    DayFeedAsset(isVideo: true) || DayFeedFolderMedia(isVideo: true) => _kVideoFallbackDuration,
    _ => DayFeedLayout.photoStoryDuration,
  };

  void _startTimer() {
    if (!widget.autoplay) return;
    _progress
      ..stop()
      ..value = 0.0
      ..duration = _durationOf(_currentItem);
    if (!_isHeld) _progress.forward();
  }

  /// Videos know their length only once loaded; the current one restarts the timer with it.
  void _onMediaDuration(String itemId, Duration duration) {
    if (!widget.autoplay || itemId != _currentItem.id || duration <= Duration.zero) return;
    _progress
      ..stop()
      ..value = 0.0
      ..duration = duration;
    if (!_isHeld) _progress.forward();
  }

  void _hold() {
    if (_isHeld) return;
    _progress.stop();
    setState(() => _isHeld = true);
  }

  void _release() {
    if (!_isHeld) return;
    setState(() => _isHeld = false);
    if (widget.autoplay && _progress.duration != null) _progress.forward();
  }

  Future<T?> _whileHeld<T>(Future<T?> Function() action) async {
    final bool wasHeld = _isHeld;
    _hold();
    final T? result = await action();
    if (mounted && !wasHeld) _release();
    return result;
  }

  void _goNext() {
    if (_index < widget.items.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else if (widget.autoplay) {
      _close();
    }
  }

  void _goPrevious() {
    if (_index > 0) _pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  /// How far the page is pulled down, by a drag or by overscrolling a mind past its top.
  double get _pullDistance => math.max(_dragOffsetY, _scrollPull);

  @override
  Widget build(BuildContext context) {
    final (:background, :foreground) = storyColorsOf(context);
    final double dismissProgress = _pullDistance.clamp(0.0, _kFadeDistance) / _kFadeDistance;
    final DayFeedItem item = _currentItem;
    final EdgeInsets safe = MediaQuery.paddingOf(context);
    // Pages fill the whole screen so the texture runs behind the header and the comment bar.
    final double commentSpace = item is DayFeedMind ? MindCommentPreview.height + 8.0 : 0.0;
    final EdgeInsets contentInsets = EdgeInsets.only(top: safe.top + _kHeaderSpace, bottom: safe.bottom + commentSpace);
    final Widget story = NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: GestureDetector(
        onVerticalDragUpdate: (details) =>
            setState(() => _dragOffsetY = (_dragOffsetY + details.delta.dy).clamp(0.0, double.infinity)),
        onVerticalDragEnd: _onVerticalDragEnd,
        onLongPressStart: widget.autoplay ? (_) => _hold() : null,
        onLongPressEnd: widget.autoplay ? (_) => _release() : null,
        child: Opacity(
          opacity: 1.0 - dismissProgress * 0.85,
          child: Stack(
            children: [
              // Only the page follows the finger; the segments, header and comment bar stay put, as when a mind
              // is pulled past its top.
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0.0, _dragOffsetY),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.items.length,
                    onPageChanged: (index) {
                      setState(() => _index = index);
                      _startTimer();
                    },
                    itemBuilder: (context, index) =>
                        _buildPage(widget.items[index], isCurrent: index == _index, insets: contentInsets),
                  ),
                ),
              ),
                for (final bool isLeft in [true, false])
                  Positioned(
                    top: contentInsets.top,
                    bottom: contentInsets.bottom,
                    left: isLeft ? 0.0 : null,
                    right: isLeft ? null : 0.0,
                    width: MediaQuery.sizeOf(context).width * _kEdgeTapShare,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: isLeft ? _goPrevious : _goNext,
                    ),
                  ),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: SafeArea(
                    bottom: false,
                    child: Column(children: [_buildSegments(foreground), _buildHeader(context, foreground)]),
                  ),
                ),
                if (item is DayFeedMind)
                  Positioned(left: 0.0, right: 0.0, bottom: 0.0, child: _buildComments(item.mind)),
              ],
            ),
        ),
      ),
    );
    final bool isWide = MediaQuery.sizeOf(context).width >= _kWideMinWidth;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _goPrevious,
        const SingleActivator(LogicalKeyboardKey.arrowRight): _goNext,
        const SingleActivator(LogicalKeyboardKey.escape): _close,
        if (widget.autoplay) const SingleActivator(LogicalKeyboardKey.space): () => _isHeld ? _release() : _hold(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: (isWide ? Colors.black : background).withValues(alpha: 1.0 - dismissProgress),
          body: isWide ? _buildWide(story, background) : story,
        ),
      ),
    );
  }

  /// On a desktop the story is a phone-shaped card in the middle, like Instagram on the web.
  Widget _buildWide(Widget story, Color background) {
    final double height = MediaQuery.sizeOf(context).height - 32.0;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: ColoredBox(
          color: background,
          child: SizedBox(width: height * 9.0 / 16.0, height: height, child: story),
        ),
      ),
    );
  }

  Widget _buildPage(DayFeedItem item, {required bool isCurrent, required EdgeInsets insets}) => switch (item) {
    DayFeedMind(:final mind) => _MindPage(
      key: ValueKey(item.id),
      initialMind: mind,
      isActive: isCurrent && !_isHeld,
      autoplayAudio: widget.autoplay && isCurrent && !_isHeld,
      insets: insets,
      onEditText: _editText,
      onVideoDuration: (duration) => _onMediaDuration(item.id, duration),
    ),
    _ => _ViewerPage(
      key: ValueKey(item.id),
      item: item,
      isActive: isCurrent && !_isHeld,
      onVideoDuration: (duration) => _onMediaDuration(item.id, duration),
    ),
  };

  Widget _buildHeader(BuildContext context, Color foreground) {
    final DayFeedItem item = _currentItem;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (item is DayFeedMind)
            Align(
              alignment: Alignment.centerLeft,
              child: _StoryMenuButton(
                color: foreground,
                actions: () => _mindActions(_liveMind(item.mind.id) ?? item.mind),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52.0),
            child: StoryDateHeader(date: item.timestamp),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(color: foreground, icon: const Icon(Icons.close), onPressed: _close),
          ),
        ],
      ),
    );
  }

  /// One segment per item; with the timer the current one fills up, otherwise it is simply lit.
  Widget _buildSegments(Color foreground) => Padding(
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
                  value: index < _index
                      ? 1.0
                      : index > _index
                      ? 0.0
                      : (widget.autoplay ? _progress.value : 1.0),
                  backgroundColor: foreground.withValues(alpha: 0.25),
                  valueColor: AlwaysStoppedAnimation<Color>(foreground),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _buildComments(Mind root) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: MindCommentPreview(root: root, onTap: () => _openComments(root)),
    ),
  );

  Future<void> _openComments(Mind root) => _whileHeld(
    () => MindCommentsSheet.show(
      context,
      root: root,
      menu: (comment) => [for (final _StoryAction action in _commentActions(comment)) action.toMenuAction()],
    ),
  );

  // Text of the mind

  Future<void> _editText(Mind mind) async {
    final String? text = await MindCreatorScreen.editText(context, initialText: mind.plainNote.trim());
    if (text == null || !mounted) return;
    context.read<MindBloc>().add(MindEdit(mind: mindWithText(mind, text)));
  }

  Future<void> _editEmotions(Mind mind) => _whileHeld(
    () => EmotionMarkingSheet.show(
      context: context,
      initialSelectedIds: mind.emotionIds.toSet(),
      onSelectionChanged: (ids) =>
          context.read<MindBloc>().add(MindSetEmotions(mindId: mind.id, emotionIds: ids.toList())),
    ),
  );

  // Comments

  List<_StoryAction> _commentActions(Mind comment) => [
    _StoryAction.edit(context, () => _editText(comment)),
    _StoryAction.emotions(context, () => _editEmotions(comment)),
    if (comment.noteContent.hasMedia) _StoryAction.removeMedia(context, comment),
    _StoryAction.delete(context, () => context.read<MindBloc>().add(MindDelete(mind: comment))),
  ];

  // The mind itself

  List<_StoryAction> _mindActions(Mind mind) {
    final DebugMenuState debugState = context.read<DebugMenuBloc>().state;
    final bool canTranslate =
        debugState is DebugMenuDataState &&
        debugState.debugMenuItems.any((item) => item.type == DebugMenuType.translation && item.value);
    return [
      _StoryAction.edit(context, () => _editText(mind)),
      _StoryAction.emotions(context, () => _editEmotions(mind)),
      if (canTranslate)
        _StoryAction(
          id: 'translate',
          title: context.l10n.translateToEnglish,
          sfSymbol: 'globe',
          icon: Icons.translate,
          run: () => _translateToEnglish(mind),
        ),
      if (mind.noteContent.hasMedia) _StoryAction.removeMedia(context, mind),
      _StoryAction.delete(context, () {
        context.read<MindBloc>().add(MindDelete(mind: mind));
        _close();
      }),
    ];
  }

  Future<void> _translateToEnglish(Mind mind) async {
    final Translation translation = await GoogleTranslator().translate(mind.plainNote, to: 'en');
    if (!mounted) return;
    await showOkAlertDialog(context: context, message: translation.text);
  }

  // Closing

  void _close() {
    if (_isClosing) return;
    _isClosing = true;
    Navigator.of(context).maybePop();
  }

  /// Pulling a mind down past its top fades the viewer with the finger and closes it on release past the
  /// threshold: bouncing scroll views report the pull as negative pixels, clamping ones as overscroll.
  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    switch (notification) {
      case ScrollUpdateNotification(dragDetails: _?):
        _setScrollPull(notification.metrics.minScrollExtent - notification.metrics.pixels);
      case OverscrollNotification(dragDetails: _?, :final overscroll):
        if (overscroll < 0) _setScrollPull(_scrollPull - overscroll);
      case ScrollUpdateNotification() || ScrollEndNotification():
        if (_scrollPull >= _kDismissOverscroll) _close();
        _setScrollPull(0.0);
      default:
        break;
    }
    return false;
  }

  void _setScrollPull(double value) {
    final double pull = math.max(0.0, value);
    if (pull != _scrollPull) setState(() => _scrollPull = pull);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffsetY > _kDismissDragDistance || (details.primaryVelocity ?? 0.0) > _kDismissDragVelocity) {
      _close();
      return;
    }
    setState(() => _dragOffsetY = 0.0);
  }
}

final class _ViewerPage extends StatelessWidget {
  final DayFeedItem item;
  final bool isActive;
  final ValueChanged<Duration> onVideoDuration;

  const _ViewerPage({super.key, required this.item, required this.isActive, required this.onVideoDuration});

  @override
  Widget build(BuildContext context) => switch (item) {
    DayFeedMind() => const SizedBox.shrink(),
    DayFeedAsset(isVideo: true) ||
    DayFeedFolderMedia(isVideo: true) => _VideoPage(item: item, isActive: isActive, onDuration: onVideoDuration),
    DayFeedAsset(:final asset) => InteractiveViewer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(image: GalleryMedia.thumbnail(asset), fit: BoxFit.contain, errorBuilder: (_, _, _) => const _Loading()),
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
    ),
    DayFeedFolderMedia(item: FolderFileItem(:final file)) => InteractiveViewer(
      child: Image.file(file, fit: BoxFit.contain),
    ),
    DayFeedFolderMedia(item: final FolderSafItem safItem) => _SafPhoto(item: safItem),
  };
}

/// A mind kept in sync with [MindBloc], on its emotion texture that moves with its audio/video.
final class _MindPage extends StatefulWidget {
  final Mind initialMind;
  final bool isActive;
  final bool autoplayAudio;
  final EdgeInsets insets;
  final ValueChanged<Mind> onEditText;
  final ValueChanged<Duration> onVideoDuration;

  const _MindPage({
    super.key,
    required this.initialMind,
    required this.isActive,
    required this.autoplayAudio,
    required this.insets,
    required this.onEditText,
    required this.onVideoDuration,
  });

  @override
  State<_MindPage> createState() => _MindPageState();
}

final class _MindPageState extends State<_MindPage> {
  final ValueNotifier<SoundPlayback?> _sound = ValueNotifier(null);

  @override
  void dispose() {
    _sound.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Mind mind =
        context.select<MindBloc, Mind?>((bloc) {
          final MindState state = bloc.state;
          return state is MindList ? state.values.firstWhereOrNull((other) => other.id == widget.initialMind.id) : null;
        }) ??
        widget.initialMind;
    final Color foreground = storyColorsOf(context).foreground;
    final MindNoteVideo? video = mind.noteContent.videoPieces.firstOrNull;
    final MindNoteAudio? audio = mind.noteContent.audioPieces.firstOrNull;
    final Color accent = mindAccentColorOf(context, mind);
    return SoundPlaybackScope(
      notifier: _sound,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedEmotionTexture(mind: mind, color: foreground),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(24.0, widget.insets.top + 8.0, 24.0, widget.insets.bottom + 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - widget.insets.vertical - 32.0),
                child: Center(
                  child: MindStoryDetails(
                    mind: mind,
                    media: video != null
                        ? SoundSpectrumRing(
                            diameter: _kRoundVideoSize,
                            color: accent,
                            child: _RoundVideoPlayer(
                              key: ValueKey(video.appRelativePath),
                              video: video,
                              isActive: widget.isActive,
                              onDuration: widget.onVideoDuration,
                            ),
                          )
                        : audio != null
                        ? MindAudioCircle(
                            key: ValueKey(audio.appRelativeAbsoulutePath),
                            audio: audio,
                            color: accent,
                            diameter: _kAudioCircleSize,
                            isPlaying: widget.autoplayAudio,
                          )
                        : null,
                    onLongPressText: () => widget.onEditText(mind),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plays while its page is current and not held; a tap pauses or resumes.
final class _RoundVideoPlayer extends StatefulWidget {
  final MindNoteVideo video;
  final bool isActive;
  final ValueChanged<Duration> onDuration;

  const _RoundVideoPlayer({super.key, required this.video, required this.isActive, required this.onDuration});

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
    final VideoPlayerController controller = videoControllerFor(path);
    await controller.initialize();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
    // The scope lives on the same page as this player, so it is never cleared.
    SoundPlaybackScope.maybeOf(context)?.value = SoundPlayback.video(controller).withEnvelopeOf(path);
    widget.onDuration(controller.value.duration);
    if (widget.isActive) unawaited(controller.play());
  }

  @override
  void didUpdateWidget(_RoundVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;
    widget.isActive ? _controller?.play() : _controller?.pause();
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

/// Library and folder videos: plays while its page is current and not held, loops, a tap pauses or resumes.
final class _VideoPage extends StatefulWidget {
  final DayFeedItem item;
  final bool isActive;
  final ValueChanged<Duration> onDuration;

  const _VideoPage({required this.item, required this.isActive, required this.onDuration});

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
      DayFeedAsset(:final asset) => await GalleryMedia.videoController(asset),
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
    widget.onDuration(controller.value.duration);
    if (widget.isActive) unawaited(controller.play());
  }

  @override
  void didUpdateWidget(_VideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;
    widget.isActive ? _controller?.play() : _controller?.pause();
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

/// One entry of a story menu, shown both as the ⋯ menu and as a comment's context menu.
final class _StoryAction {
  final String id;
  final String title;
  final String sfSymbol;
  final IconData icon;
  final bool isDestructive;
  final VoidCallback run;

  const _StoryAction({
    required this.id,
    required this.title,
    required this.sfSymbol,
    required this.icon,
    required this.run,
    this.isDestructive = false,
  });

  factory _StoryAction.edit(BuildContext context, VoidCallback run) =>
      _StoryAction(id: 'edit', title: context.l10n.edit, sfSymbol: 'pencil', icon: Icons.edit_outlined, run: run);

  factory _StoryAction.emotions(BuildContext context, VoidCallback run) => _StoryAction(
    id: 'emotions',
    title: context.l10n.emotions,
    sfSymbol: 'face.smiling',
    icon: Icons.sentiment_satisfied_alt_outlined,
    run: run,
  );

  factory _StoryAction.removeMedia(BuildContext context, Mind mind) => _StoryAction(
    id: 'removeMedia',
    title: context.l10n.removeMedia,
    sfSymbol: 'photo.badge.minus',
    icon: Icons.hide_image_outlined,
    run: () => context.read<MindBloc>().add(MindRemoveMedia(mind: mind)),
  );

  factory _StoryAction.delete(BuildContext context, VoidCallback run) => _StoryAction(
    id: 'delete',
    title: context.l10n.delete,
    sfSymbol: 'trash',
    icon: Icons.delete_outline,
    isDestructive: true,
    run: run,
  );

  MenuAction toMenuAction() => MenuAction(
    title: title,
    image: defaultTargetPlatform == TargetPlatform.iOS ? MenuImage.system(sfSymbol) : MenuImage.icon(icon),
    attributes: MenuActionAttributes(destructive: isDestructive),
    callback: run,
  );
}

/// ⋯ that opens the system pull-down menu on iOS 26+, and a Material menu elsewhere.
final class _StoryMenuButton extends StatelessWidget {
  final Color color;
  final List<_StoryAction> Function() actions;

  const _StoryMenuButton({required this.color, required this.actions});

  @override
  Widget build(BuildContext context) {
    final List<_StoryAction> items = actions();
    void select(String id) => items.firstWhereOrNull((action) => action.id == id)?.run();
    if (NativeLiquidGlassUtils.supportsLiquidGlass) {
      return LiquidGlassMenu.icon(
        icon: const NativeLiquidGlassIcon.sfSymbol('ellipsis'),
        color: color,
        items: [
          for (final _StoryAction action in items)
            LiquidGlassMenuItem(
              id: action.id,
              title: action.title,
              icon: NativeLiquidGlassIcon.sfSymbol(action.sfSymbol),
              isDestructive: action.isDestructive,
            ),
        ],
        onItemSelected: select,
      );
    }
    final Color destructive = Theme.of(context).colorScheme.error;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz_rounded, color: color),
      onSelected: select,
      itemBuilder: (_) => [
        for (final _StoryAction action in items)
          PopupMenuItem<String>(
            value: action.id,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(action.icon, color: action.isDestructive ? destructive : null),
              title: Text(action.title, style: TextStyle(color: action.isDestructive ? destructive : null)),
            ),
          ),
      ],
    );
  }
}
