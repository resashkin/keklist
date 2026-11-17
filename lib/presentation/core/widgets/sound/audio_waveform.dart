import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/files/app_file_repository.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_envelope.dart';
import 'package:material_ui/material_ui.dart';

/// The loudness of a recording as rounded bars, like a voice message; bars before [progress] are drawn in [color],
/// the rest dimmed. Fills the size it is given.
final class AudioWaveform extends StatefulWidget {
  /// App-relative path of the audio file.
  final String path;
  final Color color;

  /// 0…1 of the recording already played.
  final double progress;
  final double barWidth;
  final double gap;

  const AudioWaveform({
    super.key,
    required this.path,
    required this.color,
    this.progress = 1.0,
    this.barWidth = 3.0,
    this.gap = 2.0,
  });

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

final class _AudioWaveformState extends State<AudioWaveform> {
  SoundEnvelope? _envelope;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(AudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) unawaited(_load());
  }

  Future<void> _load() async {
    final String path = await context.read<AppFileRepository>().resolveAbsolutePath(widget.path);
    final SoundEnvelope? envelope = await SoundEnvelope.load(path);
    if (mounted) setState(() => _envelope = envelope);
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.infinite,
    painter: _WavePainter(
      levels: _envelope?.levels ?? const [],
      progress: widget.progress,
      played: widget.color,
      unplayed: widget.color.withValues(alpha: widget.color.a * 0.35),
      barWidth: widget.barWidth,
      gap: widget.gap,
    ),
  );
}

/// Rounded bars of the average level in each slice, since the loudest would flatten narrow waves;
/// bars left of [progress] are drawn in [played].
final class _WavePainter extends CustomPainter {
  final List<double> levels;
  final double progress;
  final Color played;
  final Color unplayed;
  final double barWidth;
  final double gap;

  const _WavePainter({
    required this.levels,
    required this.progress,
    required this.played,
    required this.unplayed,
    required this.barWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int count = ((size.width + gap) / (barWidth + gap)).floor();
    if (count <= 0) return;
    // Centers the bars when the width isn't a whole number of them.
    final double left = (size.width - (count * (barWidth + gap) - gap)) / 2;
    final Paint paint = Paint();
    for (int bar = 0; bar < count; bar++) {
      final double height = math.max(barWidth, _levelOf(bar, count) * size.height);
      paint.color = (bar + 0.5) / count <= progress ? played : unplayed;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left + bar * (barWidth + gap), (size.height - height) / 2, barWidth, height),
          Radius.circular(barWidth / 2),
        ),
        paint,
      );
    }
  }

  double _levelOf(int bar, int count) {
    if (levels.isEmpty) return 0.0;
    final int from = (bar * levels.length / count).floor();
    final int to = math.max(from + 1, ((bar + 1) * levels.length / count).floor()).clamp(0, levels.length);
    double sum = 0.0;
    for (int i = from; i < to; i++) {
      sum += levels[i];
    }
    return sum / (to - from);
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.progress != progress ||
      old.levels != levels ||
      old.played != played ||
      old.unplayed != unplayed ||
      old.barWidth != barWidth ||
      old.gap != gap;
}
