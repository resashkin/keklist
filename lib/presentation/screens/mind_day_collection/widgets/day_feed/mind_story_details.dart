import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_playback.dart';
import 'package:material_ui/material_ui.dart';

/// Black on dark theme, white on light, with the matching text color; shared by stories and the viewer.
({Color background, Color foreground}) storyColorsOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? (background: Colors.black, foreground: Colors.white)
    : (background: Colors.white, foreground: Colors.black);

/// "Wednesday, Oct 21 · 14:05" in a soft pill at the top of a story or viewer page.
final class StoryDatePill extends StatelessWidget {
  final DateTime date;

  const StoryDatePill({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final Color foreground = storyColorsOf(context).foreground;
    final String locale = Localizations.localeOf(context).toString();
    final DateTime local = date.toLocal();
    final String weekday = toBeginningOfSentenceCase(DateFormat.EEEE(locale).format(local));
    final String title = '$weekday, ${DateFormat.MMMd(locale).format(local)} · ${DateFormat.Hm(locale).format(local)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
      decoration: ShapeDecoration(shape: const StadiumBorder(), color: foreground.withValues(alpha: 0.1)),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w600, fontSize: 14.0),
      ),
    );
  }
}

/// Everything about a mind in a story or the viewer: emotions with their path, text, audio, comments.
/// The viewer passes the edit callbacks; stories leave them null and stay read-only.
final class MindStoryDetails extends StatelessWidget {
  final Mind mind;

  /// Shown above the emotions, e.g. the round video.
  final Widget? media;

  /// Stories play the audio themselves; the viewer shows a player.
  final bool showsAudioPlayer;

  final VoidCallback? onTapText;

  /// Replaces the text while it is being edited.
  final Widget? textEditor;

  final VoidCallback? onEditEmotions;
  final ValueChanged<Mind>? onLongPressReflection;

  const MindStoryDetails({
    super.key,
    required this.mind,
    this.media,
    this.showsAudioPlayer = false,
    this.onTapText,
    this.textEditor,
    this.onEditEmotions,
    this.onLongPressReflection,
  });

  @override
  Widget build(BuildContext context) {
    final Color foreground = storyColorsOf(context).foreground;
    final String text = mind.plainNote.trim();
    final MindNoteAudio? audio = mind.noteContent.audioPieces.firstOrNull;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20.0,
      children: [
        ?media,
        MindEmotionChips(mind: mind, onTap: onEditEmotions),
        if (textEditor != null)
          textEditor!
        else if (text.isNotEmpty)
          GestureDetector(
            onTap: onTapText,
            child: Text(text, textAlign: TextAlign.center, style: mindStoryTextStyle(foreground)),
          ),
        if (audio != null)
          showsAudioPlayer
              ? MindAudioPlayerView(audio: audio)
              : Icon(Icons.graphic_eq, color: foreground.withValues(alpha: 0.7)),
        MindReflectionsList(mind: mind, onLongPress: onLongPressReflection),
      ],
    );
  }
}

TextStyle mindStoryTextStyle(Color foreground) => TextStyle(color: foreground, fontSize: 20.0, height: 1.3);

/// "😄 Joy › Delight" for every emotion of the mind; with [onTap] the chips edit them and a "＋" chip is added.
final class MindEmotionChips extends StatelessWidget {
  final Mind mind;
  final VoidCallback? onTap;

  const MindEmotionChips({super.key, required this.mind, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (mind.emotionIds.isEmpty && onTap == null) return const SizedBox.shrink();
    final Color foreground = storyColorsOf(context).foreground;
    return BlocBuilder<EmotionBloc, EmotionState>(
      builder: (context, state) {
        if (state is! EmotionsList) return const SizedBox.shrink();
        final List<Emotion> emotions = mind.emotionIds.map(state.byId).whereType<Emotion>().toList();
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            for (final Emotion emotion in emotions)
              _chip(
                foreground,
                '${emotion.emoji} ${[...state.ancestorsOf(emotion), emotion].map((e) => e.title).join(' › ')}',
              ),
            if (onTap != null) _chip(foreground, '＋ ${context.l10n.addEmotion}', isFaint: true),
          ],
        );
      },
    );
  }

  Widget _chip(Color foreground, String title, {bool isFaint = false}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: isFaint ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        title,
        style: TextStyle(color: foreground.withValues(alpha: isFaint ? 0.6 : 1.0), fontSize: 15.0),
      ),
    ),
  );
}

/// The mind's reflections, oldest first: time, emotions and full text of each.
final class MindReflectionsList extends StatelessWidget {
  final Mind mind;
  final ValueChanged<Mind>? onLongPress;

  const MindReflectionsList({super.key, required this.mind, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final Color foreground = storyColorsOf(context).foreground;
    final String locale = Localizations.localeOf(context).toString();
    return BlocBuilder<MindBloc, MindState>(
      buildWhen: (_, current) => current is MindList,
      builder: (context, state) {
        final Iterable<Mind> all = state is MindList ? state.values : const [];
        final List<Mind> reflections = all.where((other) => other.rootId == mind.id).toList()
          ..sort((a, b) => a.creationDate.compareTo(b.creationDate));
        if (reflections.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10.0,
          children: [
            for (final Mind reflection in reflections)
              GestureDetector(
                onLongPress: onLongPress == null ? null : () => onLongPress!(reflection),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    // Opaque so the emotion texture never runs through the comment.
                    color: Color.alphaBlend(foreground.withValues(alpha: 0.07), storyColorsOf(context).background),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6.0,
                    children: [
                      Text(
                        DateFormat.yMMMd(locale).add_Hm().format(reflection.creationDate.toLocal()),
                        style: TextStyle(color: foreground.withValues(alpha: 0.55), fontSize: 12.0),
                      ),
                      if (reflection.emotionIds.isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: MindEmotionChips(mind: reflection),
                        ),
                      if (reflection.plainNote.trim().isNotEmpty)
                        Text(reflection.plainNote.trim(), style: TextStyle(color: foreground, fontSize: 16.0)),
                      if (reflection.noteContent.hasMedia)
                        Icon(
                          reflection.noteContent.hasVideo ? Icons.videocam_outlined : Icons.graphic_eq,
                          size: 18.0,
                          color: foreground.withValues(alpha: 0.55),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Play/pause, a seekable progress bar and the elapsed / total time of a voice note.
final class MindAudioPlayerView extends StatefulWidget {
  final MindNoteAudio audio;

  const MindAudioPlayerView({super.key, required this.audio});

  @override
  State<MindAudioPlayerView> createState() => _MindAudioPlayerViewState();
}

final class _MindAudioPlayerViewState extends State<MindAudioPlayerView> {
  final AudioPlayer _player = AudioPlayer();
  Duration? _duration;

  @override
  void initState() {
    super.initState();
    _duration = widget.audio.duration;
    unawaited(_load());
  }

  Future<void> _load() async {
    final String path = await context.read<AppFileRepository>().resolveAbsolutePath(
      widget.audio.appRelativeAbsoulutePath,
    );
    final Duration? loaded = await _player.setFilePath(path).catchError((_) => null);
    if (!mounted) return;
    if (loaded != null) setState(() => _duration = loaded);
    // The scope lives on the same page as this player, so it is never cleared.
    SoundPlaybackScope.maybeOf(context)?.value = SoundPlayback.audio(_player).withEnvelopeOf(path);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color foreground = storyColorsOf(context).foreground;
    return Container(
      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 16.0, 4.0),
      decoration: BoxDecoration(color: foreground.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(28.0)),
      child: StreamBuilder<PlayerState>(
        stream: _player.playerStateStream,
        builder: (context, snapshot) {
          final PlayerState? playerState = snapshot.data;
          final bool isPlaying =
              (playerState?.playing ?? false) && playerState?.processingState != ProcessingState.completed;
          return Row(
            children: [
              IconButton(
                color: foreground,
                icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 32.0),
                onPressed: () => _toggle(playerState),
              ),
              Expanded(
                child: StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, positionSnapshot) {
                    final Duration total = _duration ?? Duration.zero;
                    final Duration position = positionSnapshot.data ?? Duration.zero;
                    final double max = total.inMilliseconds.toDouble().clamp(1.0, double.infinity);
                    return Row(
                      spacing: 8.0,
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: foreground,
                              inactiveTrackColor: foreground.withValues(alpha: 0.2),
                              thumbColor: foreground,
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              value: position.inMilliseconds.toDouble().clamp(0.0, max),
                              max: max,
                              onChanged: (value) => _player.seek(Duration(milliseconds: value.round())),
                            ),
                          ),
                        ),
                        Text(
                          '${_format(position)} / ${_format(total)}',
                          style: TextStyle(color: foreground.withValues(alpha: 0.7), fontSize: 12.0),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggle(PlayerState? state) async {
    if (state?.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
      unawaited(_player.play());
      return;
    }
    (state?.playing ?? false) ? await _player.pause() : unawaited(_player.play());
  }

  static String _format(Duration duration) =>
      '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
}
