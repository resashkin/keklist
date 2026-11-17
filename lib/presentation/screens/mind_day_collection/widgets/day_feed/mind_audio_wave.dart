import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/core/helpers/emotion_colors.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_playback.dart';
import 'package:keklist/presentation/core/widgets/sound/audio_waveform.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_story_details.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/core/helpers/media_sources.dart';

/// The color of the mind's first emotion, or a neutral grey; fills its audio button and tints its spectrum.
Color mindAccentColorOf(BuildContext context, Mind mind) => context.select<EmotionBloc, Color>((bloc) {
  final EmotionState state = bloc.state;
  final String? firstEmotionId = mind.emotionIds.firstOrNull;
  if (state is! EmotionsList || firstEmotionId == null) return kEmotionPalette.last;
  return emotionColorsOf(state.emotions)[firstEmotionId] ?? kEmotionPalette.last;
});

/// A voice note as a horizontal wave, like a voice message: ▶/⏸ in the mind's emotion color, the loudness of the
/// recording as bars that fill as it plays (tap or drag them to seek), and the time.
final class MindAudioWave extends StatefulWidget {
  final MindNoteAudio audio;
  final Color color;

  /// Plays from outside, e.g. while ▶ runs through the stories.
  final bool isPlaying;

  const MindAudioWave({super.key, required this.audio, required this.color, this.isPlaying = false});

  @override
  State<MindAudioWave> createState() => _MindAudioWaveState();
}

final class _MindAudioWaveState extends State<MindAudioWave> {
  static const double _buttonSize = 44.0;
  static const double _waveHeight = 36.0;

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
    final Duration? loaded = await setAudioSource(_player, path).catchError((_) => null);
    if (!mounted) return;
    if (loaded != null) setState(() => _duration = loaded);
    // The scope lives on the same page as this player, so it is never cleared.
    SoundPlaybackScope.maybeOf(context)?.value = SoundPlayback.audio(_player).withEnvelopeOf(path);
    if (widget.isPlaying) unawaited(_player.play());
  }

  @override
  void didUpdateWidget(MindAudioWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying == oldWidget.isPlaying) return;
    widget.isPlaying ? unawaited(_player.play()) : unawaited(_player.pause());
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color foreground = storyColorsOf(context).foreground;
    return Row(
      spacing: 12.0,
      children: [
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final PlayerState? state = snapshot.data;
            final bool isPlaying = (state?.playing ?? false) && state?.processingState != ProcessingState.completed;
            return GestureDetector(
              onTap: () => _toggle(state),
              child: Container(
                width: _buttonSize,
                height: _buttonSize,
                decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
                child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
              ),
            );
          },
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              void seekTo(double dx) {
                final int total = (_duration ?? Duration.zero).inMilliseconds;
                if (total <= 0) return;
                final double fraction = (dx / constraints.maxWidth).clamp(0.0, 1.0);
                unawaited(_player.seek(Duration(milliseconds: (total * fraction).round())));
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => seekTo(details.localPosition.dx),
                onHorizontalDragUpdate: (details) => seekTo(details.localPosition.dx),
                child: StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, position) => SizedBox(
                    height: _waveHeight,
                    child: AudioWaveform(
                      path: widget.audio.appRelativeAbsoulutePath,
                      color: foreground,
                      progress: _progressOf(position.data),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        StreamBuilder<Duration>(
          stream: _player.positionStream,
          builder: (context, position) {
            final Duration shown = (position.data ?? Duration.zero) > Duration.zero
                ? position.data!
                : _duration ?? Duration.zero;
            return Text(
              _format(shown),
              style: TextStyle(
                color: foreground.withValues(alpha: 0.7),
                fontSize: 13.0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            );
          },
        ),
      ],
    );
  }

  double _progressOf(Duration? position) {
    final int total = (_duration ?? Duration.zero).inMilliseconds;
    if (total <= 0 || position == null) return 0.0;
    return (position.inMilliseconds / total).clamp(0.0, 1.0);
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
