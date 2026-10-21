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
import 'package:material_ui/material_ui.dart';

/// Black on dark theme, white on light, with the matching text color; shared by stories and the viewer.
({Color background, Color foreground}) storyColorsOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? (background: Colors.black, foreground: Colors.white)
    : (background: Colors.white, foreground: Colors.black);

/// Everything about a mind in a story or the viewer: emotions with their path, text, audio, comments.
final class MindStoryDetails extends StatelessWidget {
  final Mind mind;

  /// Shown above the emotions, e.g. the round video.
  final Widget? media;

  /// Stories play the audio themselves; the viewer shows a player.
  final bool showsAudioPlayer;

  const MindStoryDetails({super.key, required this.mind, this.media, this.showsAudioPlayer = false});

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
        MindEmotionChips(mind: mind),
        if (text.isNotEmpty)
          Text(text, textAlign: TextAlign.center, style: TextStyle(color: foreground, fontSize: 20.0, height: 1.3)),
        if (audio != null)
          showsAudioPlayer
              ? MindAudioPlayerView(audio: audio)
              : Icon(Icons.graphic_eq, color: foreground.withValues(alpha: 0.7)),
        MindReflectionsList(mind: mind),
      ],
    );
  }
}

/// "😄 Joy › Delight" for every emotion of the mind.
final class MindEmotionChips extends StatelessWidget {
  final Mind mind;

  const MindEmotionChips({super.key, required this.mind});

  @override
  Widget build(BuildContext context) {
    if (mind.emotionIds.isEmpty) return const SizedBox.shrink();
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  '${emotion.emoji} ${[...state.ancestorsOf(emotion), emotion].map((e) => e.title).join(' › ')}',
                  style: TextStyle(color: foreground, fontSize: 15.0),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// The mind's reflections, oldest first: time, emotions and full text of each.
final class MindReflectionsList extends StatelessWidget {
  final Mind mind;

  const MindReflectionsList({super.key, required this.mind});

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
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: 0.07),
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
                      Align(alignment: Alignment.centerLeft, child: MindEmotionChips(mind: reflection)),
                    if (reflection.plainNote.trim().isNotEmpty)
                      Text(reflection.plainNote.trim(), style: TextStyle(color: foreground, fontSize: 16.0)),
                  ],
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
    if (mounted && loaded != null) setState(() => _duration = loaded);
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
