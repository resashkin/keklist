import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/core/helpers/emotion_colors.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_playback.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_spectrum_ring.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_story_details.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/core/helpers/media_sources.dart';

/// The color of the mind's first emotion, or a neutral grey; fills its audio circle and tints its spectrum.
Color mindAccentColorOf(BuildContext context, Mind mind) => context.select<EmotionBloc, Color>((bloc) {
  final EmotionState state = bloc.state;
  final String? firstEmotionId = mind.emotionIds.firstOrNull;
  if (state is! EmotionsList || firstEmotionId == null) return kEmotionPalette.last;
  return emotionColorsOf(state.emotions)[firstEmotionId] ?? kEmotionPalette.last;
});

/// A voice note as a circle in the mind's emotion color, like round videos: ▶/⏸ in the middle, a progress ring,
/// the spectrum around it and a seek bar below. Stories pass their own [player] and get a display-only circle.
final class MindAudioCircle extends StatefulWidget {
  final MindNoteAudio audio;
  final Color color;
  final double diameter;
  final AudioPlayer? player;

  /// Plays its own player from outside, e.g. while ▶ runs through the stories.
  final bool isPlaying;

  const MindAudioCircle({
    super.key,
    required this.audio,
    required this.color,
    required this.diameter,
    this.player,
    this.isPlaying = false,
  });

  @override
  State<MindAudioCircle> createState() => _MindAudioCircleState();
}

final class _MindAudioCircleState extends State<MindAudioCircle> {
  AudioPlayer? _ownPlayer;
  Duration? _duration;

  AudioPlayer get _player => widget.player ?? _ownPlayer!;
  bool get _isInteractive => widget.player == null;

  @override
  void initState() {
    super.initState();
    _duration = widget.audio.duration;
    if (_isInteractive) {
      _ownPlayer = AudioPlayer();
      unawaited(_load());
    }
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
  void didUpdateWidget(MindAudioCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isInteractive || widget.isPlaying == oldWidget.isPlaying) return;
    widget.isPlaying ? unawaited(_player.play()) : unawaited(_player.pause());
  }

  @override
  void dispose() {
    _ownPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color foreground = storyColorsOf(context).foreground;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16.0,
      children: [
        SoundSpectrumRing(
          diameter: widget.diameter,
          color: widget.color,
          child: StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, snapshot) {
              final PlayerState? state = snapshot.data;
              final bool isPlaying = (state?.playing ?? false) && state?.processingState != ProcessingState.completed;
              return GestureDetector(
                onTap: _isInteractive ? () => _toggle(state) : null,
                child: DecoratedBox(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      StreamBuilder<Duration>(
                        stream: _player.positionStream,
                        builder: (context, position) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircularProgressIndicator(
                            value: _progressOf(position.data),
                            strokeWidth: 4.0,
                            strokeCap: StrokeCap.round,
                            color: Colors.white,
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                      Icon(
                        _isInteractive
                            ? (isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded)
                            : Icons.graphic_eq_rounded,
                        color: Colors.white,
                        size: widget.diameter * 0.32,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_isInteractive) _buildSeekBar(foreground),
      ],
    );
  }

  Widget _buildSeekBar(Color foreground) {
    return StreamBuilder<Duration>(
      stream: _player.positionStream,
      builder: (context, snapshot) {
        final Duration total = _duration ?? Duration.zero;
        final Duration position = snapshot.data ?? Duration.zero;
        final double max = total.inMilliseconds.toDouble().clamp(1.0, double.infinity);
        return Row(
          spacing: 8.0,
          children: [
            Text(_format(position), style: TextStyle(color: foreground.withValues(alpha: 0.7), fontSize: 12.0)),
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
            Text(_format(total), style: TextStyle(color: foreground.withValues(alpha: 0.7), fontSize: 12.0)),
          ],
        );
      },
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
