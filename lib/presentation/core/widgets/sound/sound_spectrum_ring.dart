import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/core/extensions/story_settings_extension.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_playback.dart';
import 'package:material_ui/material_ui.dart';

const int _kRayCount = 56;
const double _kRayGap = 6.0;
const double _kRayWidth = 3.0;
const double _kSmoothing = 0.3;

/// The length of ray [index] of [count] at [time] seconds, as a share of the longest ray, for a [level] of 0…1.
/// Neighbouring rays move differently so the ring reads as a spectrum although only loudness is known.
double spectrumRayLength({required int index, required int count, required double level, required double time}) {
  if (level <= 0.0) return 0.0;
  final double angle = index / count * math.pi * 2;
  final double shape = (math.sin(angle * 3 + time * 7.0) * math.cos(angle * 5 - time * 3.0)).abs();
  return (level * (0.35 + 0.65 * shape)).clamp(0.0, 1.0);
}

/// Rays around a circle of [diameter] that grow with the sound [SoundPlaybackScope] reports and reach past the
/// circle when it is loud; follows the spectrum switch and sensitivity of the story tweaks.
final class SoundSpectrumRing extends StatefulWidget {
  final double diameter;
  final Color color;
  final Widget child;

  const SoundSpectrumRing({super.key, required this.diameter, required this.color, required this.child});

  @override
  State<SoundSpectrumRing> createState() => _SoundSpectrumRingState();
}

final class _SoundSpectrumRingState extends State<SoundSpectrumRing> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  final ValueNotifier<({double level, double time})> _frame = ValueNotifier((level: 0.0, time: 0.0));
  SoundPlayback? _playback;
  double _sensitivity = 1.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playback = SoundPlaybackScope.watch(context);
    if (!_ticker.isActive) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final double target = ((_playback?.level ?? 0.0) * _sensitivity).clamp(0.0, 1.0);
    final double level = _frame.value.level + (target - _frame.value.level) * _kSmoothing;
    if (level < 0.001 && _frame.value.level < 0.001) return;
    _frame.value = (level: level, time: elapsed.inMicroseconds / Duration.microsecondsPerSecond);
  }

  @override
  Widget build(BuildContext context) {
    final StorySettings story = context.watchStorySettings();
    _sensitivity = story.sensitivity;
    return SizedBox.square(
      dimension: widget.diameter,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          if (story.isSpectrumVisible)
            IgnorePointer(
              child: CustomPaint(
                painter: _SpectrumPainter(frame: _frame, color: widget.color, maxRayLength: widget.diameter * 0.45),
              ),
            ),
          widget.child,
        ],
      ),
    );
  }
}

final class _SpectrumPainter extends CustomPainter {
  final ValueNotifier<({double level, double time})> frame;
  final Color color;
  final double maxRayLength;

  _SpectrumPainter({required this.frame, required this.color, required this.maxRayLength}) : super(repaint: frame);

  @override
  void paint(Canvas canvas, Size size) {
    final ({double level, double time}) current = frame.value;
    if (current.level <= 0.001) return;
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2 + _kRayGap;
    final Paint paint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..strokeWidth = _kRayWidth
      ..strokeCap = StrokeCap.round;
    for (int index = 0; index < _kRayCount; index++) {
      final double length =
          spectrumRayLength(index: index, count: _kRayCount, level: current.level, time: current.time) * maxRayLength;
      if (length < 1.0) continue;
      final double angle = index / _kRayCount * math.pi * 2 - math.pi / 2;
      final Offset direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(center + direction * radius, center + direction * (radius + length), paint);
    }
  }

  @override
  bool shouldRepaint(_SpectrumPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.maxRayLength != maxRayLength || oldDelegate.frame != frame;
}
