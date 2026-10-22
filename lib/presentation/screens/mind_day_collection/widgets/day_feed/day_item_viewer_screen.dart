import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'dart:typed_data';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:keklist/domain/repositories/debug_menu/debug_menu_repository.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/native/android/media_folder_channel.dart';
import 'package:keklist/presentation/blocs/debug_menu_bloc/debug_menu_bloc.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/shake/shake_to_tweak_mixin.dart';
import 'package:keklist/presentation/core/widgets/creator_bottom_bar/mind_creator_bottom_bar.dart';
import 'package:keklist/presentation/core/widgets/gallery/cached_asset_thumbnail_provider.dart';
import 'package:keklist/presentation/core/widgets/round_video/media_recording.dart';
import 'package:keklist/presentation/core/widgets/round_video/round_video_views.dart';
import 'package:keklist/presentation/core/widgets/sound/animated_emotion_texture.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_playback.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_spectrum_ring.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_audio_circle.dart';
import 'package:keklist/presentation/screens/actions/action_model.dart';
import 'package:keklist/presentation/screens/actions/actions_screen.dart';
import 'package:keklist/presentation/screens/emotions/emotion_marking_sheet.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/folder_media_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_story_details.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/story_texture_tweak_sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:translator/translator.dart';
import 'package:video_player/video_player.dart';

const double _kDismissDragDistance = 120.0;
const double _kDismissDragVelocity = 700.0;
const double _kDismissOverscroll = 80.0;
const double _kRoundVideoSize = 260.0;
const double _kAudioCircleSize = 200.0;
const double _kFadeDistance = 320.0;
const double _kHeaderSpace = 88.0;
const double _kCommentBarSpace = 84.0;

/// A calm look at one tile at a time: swipe between the day's items, no progress bars, no timer.
/// Minds are edited right here: tap the text, the emotions, comment below, ⋯ for the rest. Swipe down or ✕ closes it.
final class DayItemViewerScreen extends StatefulWidget {
  final List<DayFeedItem> items;
  final int initialIndex;

  const DayItemViewerScreen({super.key, required this.items, required this.initialIndex});

  /// Pushed over the current screen with a fade, like the stories.
  static Future<void> show(BuildContext context, {required List<DayFeedItem> items, required int initialIndex}) {
    if (items.isEmpty) return Future.value();
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        fullscreenDialog: true,
        pageBuilder: (_, _, _) =>
            DayItemViewerScreen(items: items, initialIndex: initialIndex.clamp(0, items.length - 1)),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  /// A single mind, e.g. from search or the digest.
  static Future<void> showMind(BuildContext context, Mind mind) =>
      show(context, items: [DayFeedMind(mind: mind, reflectionCount: 0)], initialIndex: 0);

  @override
  State<DayItemViewerScreen> createState() => _DayItemViewerScreenState();
}

final class _DayItemViewerScreenState extends State<DayItemViewerScreen> with ShakeToTweakMixin {
  late final PageController _pageController = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  double _dragOffsetY = 0.0;
  double _scrollPull = 0.0;
  bool _isClosing = false;

  final TextEditingController _textController = TextEditingController();
  String? _editingMindId;

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  Mind? _editableComment;

  DayFeedItem get _currentItem => widget.items[_index];

  @override
  String get shakeScreenId => ShakeScreenIds.story;

  @override
  void onShakeToTweak() => StoryTextureTweakSheet.show(context);

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Mind? _liveMind(String id) {
    final MindState state = context.read<MindBloc>().state;
    return state is MindList ? state.values.firstWhereOrNull((mind) => mind.id == id) : null;
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
    final EdgeInsets contentInsets = EdgeInsets.only(
      top: safe.top + _kHeaderSpace,
      bottom: safe.bottom + (item is DayFeedMind ? _kCommentBarSpace : 0.0) + (widget.items.length > 1 ? 34.0 : 0.0),
    );
    return Scaffold(
      backgroundColor: background.withValues(alpha: 1.0 - dismissProgress),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: GestureDetector(
          onVerticalDragUpdate: (details) =>
              setState(() => _dragOffsetY = (_dragOffsetY + details.delta.dy).clamp(0.0, double.infinity)),
          onVerticalDragEnd: _onVerticalDragEnd,
          child: Opacity(
            opacity: 1.0 - dismissProgress * 0.85,
            child: Transform.translate(
              offset: Offset(0.0, _dragOffsetY),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.items.length,
                      onPageChanged: (index) => setState(() {
                        _index = index;
                        _editingMindId = null;
                        _resetComment();
                      }),
                      itemBuilder: (context, index) =>
                          _buildPage(widget.items[index], isCurrent: index == _index, insets: contentInsets),
                    ),
                  ),
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: SafeArea(bottom: false, child: _buildHeader(context, foreground)),
                  ),
                  Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.items.length > 1) _buildPageDots(foreground),
                        if (item is DayFeedMind) _buildCommentBar(item.mind) else SizedBox(height: safe.bottom),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(DayFeedItem item, {required bool isCurrent, required EdgeInsets insets}) => switch (item) {
    DayFeedMind(:final mind) => _MindPage(
      key: ValueKey(item.id),
      initialMind: mind,
      isCurrent: isCurrent,
      insets: insets,
      isEditing: _editingMindId == mind.id,
      textController: _textController,
      onStartEditing: _startEditing,
      onSaveEditing: _saveEditing,
      onCancelEditing: () => setState(() => _editingMindId = null),
      onEditEmotions: _editEmotions,
      onLongPressReflection: _showCommentActions,
    ),
    _ => _ViewerPage(key: ValueKey(item.id), item: item, isCurrent: isCurrent),
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
              child: IconButton(
                color: foreground,
                icon: const Icon(Icons.more_horiz_rounded),
                onPressed: () => _showMindActions(_liveMind(item.mind.id) ?? item.mind),
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

  Widget _buildCommentBar(Mind root) {
    final bool hasText = _commentController.text.trim().isNotEmpty;
    final ThemeData theme = Theme.of(context);
    return Theme(
      // See-through so the mind's texture continues under the comment field.
      data: theme.copyWith(scaffoldBackgroundColor: Colors.transparent),
      child: MindCreatorBottomBar(
        editableMind: _editableComment,
        focusNode: _commentFocusNode,
        textEditingController: _commentController,
        placeholder: context.l10n.viewerCommentHint,
        doneTitle: context.l10n.save,
        onDone: (data) => _saveComment(root, data.text),
        onTapCancelEdit: () => setState(_resetComment),
        onRecordAudio: hasText ? null : () => _recordComment(root, MediaRecording.recordAudio),
        onRecordVideo: hasText ? null : () => _recordComment(root, MediaRecording.recordVideo),
      ),
    );
  }

  // Text of the mind

  void _startEditing(Mind mind) {
    final String text = mind.plainNote.trim();
    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() => _editingMindId = mind.id);
  }

  void _saveEditing(Mind mind) {
    context.read<MindBloc>().add(MindEdit(mind: _withText(mind, _textController.text)));
    setState(() => _editingMindId = null);
  }

  void _editEmotions(Mind mind) {
    EmotionMarkingSheet.show(
      context: context,
      initialSelectedIds: mind.emotionIds.toSet(),
      onSelectionChanged: (ids) =>
          context.read<MindBloc>().add(MindSetEmotions(mindId: mind.id, emotionIds: ids.toList())),
    );
  }

  /// Keeps the audio/video of the mind and replaces its text.
  static Mind _withText(Mind mind, String newText) {
    final List<BaseMindNotePiece> keptMedia = mind.noteContent.pieces
        .where((piece) => piece is MindNoteAudio || piece is MindNoteVideo)
        .toList();
    final String text = newText.trim();
    final MindNoteContent edited = MindNoteContent.fromPieces([
      ...keptMedia,
      if (text.isNotEmpty) MindNoteText(keptMedia.isEmpty ? text : '\n$text'),
    ]);
    return mind.copyWith(note: edited.toRawNoteString());
  }

  // Comments

  void _saveComment(Mind root, String text) {
    final Mind? editable = _editableComment;
    if (editable != null) {
      context.read<MindBloc>().add(MindEdit(mind: _withText(editable, text)));
    } else if (text.trim().isNotEmpty) {
      context.read<MindBloc>().add(
        MindCreate(dayIndex: root.dayIndex, mindContent: MindNoteContent.parse(text.trim()).pieces, rootId: root.id),
      );
    }
    setState(_resetComment);
  }

  Future<void> _recordComment(Mind root, Future<BaseMindNotePiece?> Function(BuildContext) record) async {
    final BaseMindNotePiece? media = await record(context);
    if (media == null || !mounted) return;
    context.read<MindBloc>().add(MindCreate(dayIndex: root.dayIndex, mindContent: [media], rootId: root.id));
  }

  void _resetComment() {
    _editableComment = null;
    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  void _showCommentActions(Mind comment) {
    Haptics.vibrate(HapticsType.medium);
    showBarModalBottomSheet(
      context: context,
      builder: (_) => ActionsScreen(
        actions: [
          (
            ActionModel.edit(context),
            () {
              setState(() => _editableComment = comment);
              _commentController.text = comment.plainNote.trim();
              _commentFocusNode.requestFocus();
            },
          ),
          if (comment.noteContent.hasMedia)
            (
              ActionModel.custom(title: context.l10n.removeMedia, icon: const Icon(Icons.hide_image_outlined)),
              () => context.read<MindBloc>().add(MindRemoveMedia(mind: comment)),
            ),
          (ActionModel.delete(context), () => context.read<MindBloc>().add(MindDelete(mind: comment))),
        ],
      ),
    );
  }

  // The mind itself

  void _showMindActions(Mind mind) {
    final DebugMenuState debugState = context.read<DebugMenuBloc>().state;
    final bool canTranslate =
        debugState is DebugMenuDataState &&
        debugState.debugMenuItems.any((item) => item.type == DebugMenuType.translation && item.value);
    showBarModalBottomSheet(
      context: context,
      builder: (_) => ActionsScreen(
        actions: [
          (ActionModel.edit(context), () => _startEditing(mind)),
          if (canTranslate) (ActionModel.tranlsateToEnglish(context), () => _translateToEnglish(mind)),
          if (mind.noteContent.hasMedia)
            (
              ActionModel.custom(title: context.l10n.removeMedia, icon: const Icon(Icons.hide_image_outlined)),
              () => context.read<MindBloc>().add(MindRemoveMedia(mind: mind)),
            ),
          (
            ActionModel.delete(context),
            () {
              context.read<MindBloc>().add(MindDelete(mind: mind));
              _close();
            },
          ),
        ],
      ),
    );
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
      case OverscrollNotification(dragDetails: _?, :final overscroll) when overscroll < 0:
        _setScrollPull(_scrollPull - overscroll);
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
  final bool isCurrent;

  const _ViewerPage({super.key, required this.item, required this.isCurrent});

  @override
  Widget build(BuildContext context) => switch (item) {
    DayFeedMind() => const SizedBox.shrink(),
    DayFeedAsset(isVideo: true) || DayFeedFolderMedia(isVideo: true) => _VideoPage(item: item, isCurrent: isCurrent),
    DayFeedAsset(:final asset) => InteractiveViewer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: CachedAssetThumbnailProvider(asset),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const _Loading(),
          ),
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
    DayFeedFolderMedia(item: FolderFileItem(:final file)) => InteractiveViewer(
      child: Image.file(file, fit: BoxFit.contain),
    ),
    DayFeedFolderMedia(item: final FolderSafItem safItem) => _SafPhoto(item: safItem),
  };
}

/// A mind kept in sync with [MindBloc], on its emotion texture that moves with its audio/video.
final class _MindPage extends StatefulWidget {
  final Mind initialMind;
  final bool isCurrent;
  final EdgeInsets insets;
  final bool isEditing;
  final TextEditingController textController;
  final ValueChanged<Mind> onStartEditing;
  final ValueChanged<Mind> onSaveEditing;
  final VoidCallback onCancelEditing;
  final ValueChanged<Mind> onEditEmotions;
  final ValueChanged<Mind> onLongPressReflection;

  const _MindPage({
    super.key,
    required this.initialMind,
    required this.isCurrent,
    required this.insets,
    required this.isEditing,
    required this.textController,
    required this.onStartEditing,
    required this.onSaveEditing,
    required this.onCancelEditing,
    required this.onEditEmotions,
    required this.onLongPressReflection,
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
                              isCurrent: widget.isCurrent,
                            ),
                          )
                        : audio != null
                        ? MindAudioCircle(
                            key: ValueKey(audio.appRelativeAbsoulutePath),
                            audio: audio,
                            color: accent,
                            diameter: _kAudioCircleSize,
                          )
                        : null,
                    onTapText: () => widget.onStartEditing(mind),
                    textEditor: widget.isEditing ? _buildEditor(mind, foreground) : null,
                    onEditEmotions: () => widget.onEditEmotions(mind),
                    onLongPressReflection: widget.onLongPressReflection,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(Mind mind, Color foreground) {
    return Column(
      spacing: 8.0,
      children: [
        TextField(
          controller: widget.textController,
          autofocus: true,
          maxLines: null,
          textAlign: TextAlign.center,
          cursorColor: foreground,
          style: mindStoryTextStyle(foreground),
          decoration: InputDecoration(
            filled: true,
            fillColor: foreground.withValues(alpha: 0.06),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide.none),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12.0,
          children: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: foreground),
              onPressed: widget.onCancelEditing,
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: foreground,
                foregroundColor: storyColorsOf(context).background,
              ),
              onPressed: () => widget.onSaveEditing(mind),
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ],
    );
  }
}

/// Plays while its page is current; a tap pauses or resumes.
final class _RoundVideoPlayer extends StatefulWidget {
  final MindNoteVideo video;
  final bool isCurrent;

  const _RoundVideoPlayer({super.key, required this.video, required this.isCurrent});

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
    // The scope lives on the same page as this player, so it is never cleared.
    SoundPlaybackScope.maybeOf(context)?.value = SoundPlayback.video(controller).withEnvelopeOf(path);
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
      DayFeedAsset(:final asset) => await asset.file.then(
        (file) => file == null ? null : VideoPlayerController.file(file),
      ),
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
