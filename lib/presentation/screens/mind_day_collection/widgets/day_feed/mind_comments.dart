import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/blocs/user_profile_bloc/user_profile_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/extensions/story_settings_extension.dart';
import 'package:keklist/presentation/core/helpers/media_sources.dart';
import 'package:keklist/presentation/core/widgets/images/mind_images.dart';
import 'package:keklist/presentation/core/widgets/round_video/media_recording.dart';
import 'package:keklist/presentation/core/widgets/round_video/round_video_views.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_profile_header.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_story_details.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/core/widgets/sound/audio_waveform.dart';
import 'package:super_context_menu/super_context_menu.dart';

/// Comments of a story mind, like replies to an Instagram story: the last ones float over the story above the input,
/// and older ones scroll up from under a fade.
abstract final class MindComments {
  static List<Mind> of(BuildContext context, String rootId) {
    final MindState state = context.read<MindBloc>().state;
    return state is MindList ? mindReflectionsOf(state.values, rootId) : const [];
  }

  /// [rootId] is a mind's id, or a gallery item's day feed id (`asset_…`, `file_…`) for comments on a phone photo.
  static void save(
    BuildContext context, {
    required String rootId,
    required int dayIndex,
    required String text,
    List<MindNoteImage> images = const [],
  }) {
    final String trimmed = text.trim();
    if (trimmed.isEmpty && images.isEmpty) return;
    final List<BaseMindNotePiece> pieces = [
      ...images,
      if (trimmed.isNotEmpty) MindNoteText(images.isEmpty ? trimmed : '\n$trimmed'),
    ];
    context.read<MindBloc>().add(MindCreate(dayIndex: dayIndex, mindContent: pieces, rootId: rootId));
  }

  static void sendRecording(
    BuildContext context, {
    required String rootId,
    required int dayIndex,
    required BaseMindNotePiece media,
  }) => context.read<MindBloc>().add(MindCreate(dayIndex: dayIndex, mindContent: [media], rootId: rootId));
}

/// The mind's comments over the story, newest at the bottom: about three show, older ones scroll up and fade out
/// at the top. Long-press a comment for its [menu].
final class MindReplies extends StatelessWidget {
  final String rootId;
  final List<MenuElement> Function(Mind comment) menu;
  final VoidCallback? onImagesOpened;
  final VoidCallback? onImagesClosed;

  const MindReplies({super.key, required this.rootId, required this.menu, this.onImagesOpened, this.onImagesClosed});

  static const double _fadeSpace = 48.0;

  /// Room for [StorySettings.replyCount] one-line replies, plus the fade above them.
  static double _maxHeight(StorySettings story) {
    final double row = story.replyTextSize * 1.3 + 18.0 + (story.isReplyTimeVisible ? 19.0 : 0.0) + 8.0;
    return _fadeSpace + row * story.replyCount;
  }

  @override
  Widget build(BuildContext context) {
    final StorySettings story = context.watchStorySettings();
    return BlocBuilder<MindBloc, MindState>(
      buildWhen: (_, current) => current is MindList,
      builder: (context, state) {
        final List<Mind> comments = state is MindList ? mindReflectionsOf(state.values, rootId) : const [];
        if (comments.isEmpty) return const SizedBox.shrink();
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: _maxHeight(story)),
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black],
              stops: [0.0, 0.25],
            ).createShader(bounds),
            child: ListView.builder(
              shrinkWrap: true,
              reverse: true,
              padding: const EdgeInsets.fromLTRB(12.0, _fadeSpace, 12.0, 4.0),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final Mind comment = comments[comments.length - 1 - index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ContextMenuWidget(
                    menuProvider: (_) => Menu(children: menu(comment)),
                    child: _ReplyRow(
                      key: ValueKey(comment.id),
                      comment: comment,
                      story: story,
                      onImagesOpened: onImagesOpened,
                      onImagesClosed: onImagesClosed,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Avatar, then the time and the comment in a dark glass bubble.
final class _ReplyRow extends StatelessWidget {
  final Mind comment;
  final StorySettings story;
  final VoidCallback? onImagesOpened;
  final VoidCallback? onImagesClosed;

  const _ReplyRow({super.key, required this.comment, required this.story, this.onImagesOpened, this.onImagesClosed});

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final DateTime date = comment.creationDate.toLocal();
    final bool isToday = DateUtils.isSameDay(date, DateTime.now());
    final String time = (isToday ? DateFormat.Hm(locale) : DateFormat.MMMd(locale).add_Hm()).format(date);
    final MindNoteVideo? video = comment.noteContent.videoPieces.firstOrNull;
    final MindNoteAudio? audio = comment.noteContent.audioPieces.firstOrNull;
    final List<MindNoteImage> images = comment.noteContent.imagePieces;
    final String text = comment.plainNote.trim();
    final Color foreground = storyColorsOf(context).foreground;
    final bool isRight = story.replySide == StoryReplySide.right;
    final Widget bubbles = Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4.0,
      children: [
        if (story.isReplyTimeVisible)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(time, style: TextStyle(color: foreground.withValues(alpha: 0.6), fontSize: 11.0)),
          ),
        if (video != null) RoundVideoMessage(video: video, size: 120.0),
        if (images.isNotEmpty)
          MindImageGrid(images: images, width: 120.0, onOpen: onImagesOpened, onClose: onImagesClosed),
        if (audio != null)
          _ReplyBubble(
            opacity: story.replyOpacity,
            child: _AudioReply(audio: audio),
          ),
        if (text.isNotEmpty)
          _ReplyBubble(
            opacity: story.replyOpacity,
            child: Text(
              text,
              style: TextStyle(color: foreground, fontSize: story.replyTextSize, height: 1.3),
            ),
          ),
      ],
    );
    final List<Widget> children = [
      if (story.replyAvatarSize > 0.0)
        UserAvatarView(profile: context.watch<UserProfileBloc>().state, size: story.replyAvatarSize),
      Flexible(child: bubbles),
      // Leaves the other side to the story, as in Instagram.
      const SizedBox(width: 32.0),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      spacing: 8.0,
      children: isRight ? children.reversed.toList() : children,
    );
  }
}

final class _ReplyBubble extends StatelessWidget {
  final double opacity;
  final Widget child;

  const _ReplyBubble({required this.opacity, required this.child});

  @override
  Widget build(BuildContext context) {
    final (:background, :foreground) = storyColorsOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(foreground.withValues(alpha: opacity), background),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 9.0), child: child),
    );
  }
}

/// ▶, the waveform and the length of a voice comment; a tap plays or pauses it.
final class _AudioReply extends StatefulWidget {
  final MindNoteAudio audio;

  const _AudioReply({required this.audio});

  @override
  State<_AudioReply> createState() => _AudioReplyState();
}

final class _AudioReplyState extends State<_AudioReply> {
  final AudioPlayer _player = AudioPlayer();
  late Duration? _duration = widget.audio.duration;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final String path = await context.read<AppFileRepository>().resolveAbsolutePath(
      widget.audio.appRelativeAbsoulutePath,
    );
    final Duration? loaded = await setAudioSource(_player, path).catchError((_) => null);
    if (mounted && loaded != null) setState(() => _duration = loaded);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  double _progressOf(Duration? position) {
    final int total = (_duration ?? Duration.zero).inMilliseconds;
    if (total <= 0 || position == null || position == Duration.zero) return 1.0;
    return (position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  void _toggle(PlayerState? state) {
    if (state?.processingState == ProcessingState.completed) {
      unawaited(_player.seek(Duration.zero));
      unawaited(_player.play());
    } else {
      state?.playing ?? false ? unawaited(_player.pause()) : unawaited(_player.play());
    }
  }

  @override
  Widget build(BuildContext context) {
    final Duration length = _duration ?? Duration.zero;
    final String label = '${length.inMinutes}:${(length.inSeconds % 60).toString().padLeft(2, '0')}';
    final Color foreground = storyColorsOf(context).foreground;
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final PlayerState? state = snapshot.data;
        final bool isPlaying = (state?.playing ?? false) && state?.processingState != ProcessingState.completed;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _toggle(state),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8.0,
            children: [
              Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: foreground, size: 22.0),
              SizedBox(
                width: 72.0,
                height: 22.0,
                child: StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, position) => AudioWaveform(
                    path: widget.audio.appRelativeAbsoulutePath,
                    color: foreground,
                    progress: _progressOf(position.data),
                    barWidth: 2.0,
                    gap: 1.5,
                  ),
                ),
              ),
              Text(label, style: TextStyle(color: foreground, fontSize: 14.0)),
            ],
          ),
        );
      },
    );
  }
}

/// The chat's input bar for comments: a rounded field and one round white button that sends the text, or records
/// audio or video (tap switches, hold records) while the field is empty.
final class MindCommentBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final ValueChanged<BaseMindNotePiece> onRecorded;
  final ValueChanged<bool>? onRecordingChanged;
  final bool autofocus;

  /// Photos picked for the next reply, shown above the field; [onAddImages] is null where photos can't be added.
  final List<MindNoteImage> images;
  final VoidCallback? onAddImages;
  final ValueChanged<List<MindNoteImage>>? onImagesChanged;

  const MindCommentBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onRecorded,
    this.onRecordingChanged,
    this.autofocus = false,
    this.images = const [],
    this.onAddImages,
    this.onImagesChanged,
  });

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: controller, builder: (context, _) => _build(context));

  Widget _build(BuildContext context) {
    final bool canSend = controller.text.trim().isNotEmpty || images.isNotEmpty;
    final VoidCallback? onAddImages = images.length < kMaxMindImages ? this.onAddImages : null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 4.0, 8.0, 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8.0,
          children: [
            if (images.isNotEmpty && onImagesChanged != null)
              MindImageStrip(images: images, onChanged: onImagesChanged!, padding: EdgeInsets.zero),
            _buildRow(context, canSend: canSend, onAddImages: onAddImages),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, {required bool canSend, required VoidCallback? onAddImages}) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    spacing: 4.0,
    children: [
      Expanded(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          minLines: 1,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: context.l10n.viewerCommentHint,
            filled: true,
            // Opaque, so the emotion texture never runs through the field.
            fillColor: Color.alphaBlend(
              storyColorsOf(context).foreground.withValues(alpha: 0.1),
              storyColorsOf(context).background,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.0), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            suffixIcon: onAddImages == null
                ? null
                : IconButton(
                    onPressed: onAddImages,
                    tooltip: context.l10n.attachImages,
                    icon: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: storyColorsOf(context).foreground.withValues(alpha: 0.7),
                    ),
                  ),
          ),
        ),
      ),
      SizedBox.square(
        dimension: 52.0,
        child: canSend
            ? IconButton.filled(
                onPressed: onSend,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  fixedSize: const Size.square(52.0),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.arrow_upward_rounded),
              )
            : MediaRecordToggleButton(isFilled: true, onRecorded: onRecorded, onRecordingChanged: onRecordingChanged),
      ),
    ],
  );
}
