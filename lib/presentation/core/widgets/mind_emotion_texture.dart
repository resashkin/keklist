import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// A mind's emotion emojis repeated as a faint, tilted pattern that fills its parent and slowly moves the way
/// the tweak sheet picked ([TileEmojiMotion]); it stays still when the system asks for less motion.
final class MindEmotionTexture extends StatelessWidget {
  final Mind mind;
  final double emojiSize;
  final double opacity;

  const MindEmotionTexture({super.key, required this.mind, required this.emojiSize, this.opacity = 0.2});

  @override
  Widget build(BuildContext context) {
    if (mind.emotionIds.isEmpty) return const SizedBox.shrink();
    final TileEmojiMotion motion = context.select<SettingsBloc, TileEmojiMotion>(
      (bloc) => switch (bloc.state) {
        SettingsDataState(:final settings) => settings.tileEmojiMotion,
        _ => TileEmojiMotion.drift,
      },
    );
    return BlocBuilder<EmotionBloc, EmotionState>(
      builder: (context, state) {
        if (state is! EmotionsList) return const SizedBox.shrink();
        final List<String> emojis = mind.emotionIds.map(state.byId).whereType<Emotion>().map((e) => e.emoji).toList();
        if (emojis.isEmpty) return const SizedBox.shrink();
        return IgnorePointer(
          child: ExcludeSemantics(
            child: Opacity(
              // Light backgrounds make the pattern louder than the text on top of it.
              opacity: Theme.of(context).brightness == Brightness.light ? opacity * 0.5 : opacity,
              child: RepaintBoundary(
                child: _MovingPattern(
                  emojis: emojis,
                  emojiSize: emojiSize,
                  motion: MediaQuery.disableAnimationsOf(context) ? TileEmojiMotion.still : motion,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

final class _MovingPattern extends StatefulWidget {
  final List<String> emojis;
  final double emojiSize;
  final TileEmojiMotion motion;

  const _MovingPattern({required this.emojis, required this.emojiSize, required this.motion});

  @override
  State<_MovingPattern> createState() => _MovingPatternState();
}

final class _MovingPatternState extends State<_MovingPattern> with SingleTickerProviderStateMixin {
  // One drift period moves the pattern by a whole cell, so it loops without a seam.
  static const Duration _period = Duration(seconds: 12);

  late final AnimationController _clock = AnimationController(vsync: this, duration: _period);

  @override
  void initState() {
    super.initState();
    _syncClock();
  }

  @override
  void didUpdateWidget(_MovingPattern oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motion != widget.motion) _syncClock();
  }

  void _syncClock() => widget.motion == TileEmojiMotion.still ? _clock.stop() : _clock.repeat();

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.infinite,
    painter: _PatternPainter(emojis: widget.emojis, emojiSize: widget.emojiSize, motion: widget.motion, clock: _clock),
  );
}

final class _PatternPainter extends CustomPainter {
  final List<String> emojis;
  final double emojiSize;
  final TileEmojiMotion motion;
  final Animation<double> clock;
  final Map<String, TextPainter> _glyphs;

  _PatternPainter({required this.emojis, required this.emojiSize, required this.motion, required this.clock})
    : _glyphs = {
        for (final String emoji in emojis.toSet())
          emoji: TextPainter(
            text: TextSpan(
              text: emoji,
              style: TextStyle(fontSize: emojiSize, height: 1.0),
            ),
            textDirection: TextDirection.ltr,
          )..layout(),
      },
      super(repaint: clock);

  static const double _tilt = -math.pi / 12;
  static const int _floatCycles = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final double step = emojiSize * 1.6;
    // The rotated pattern must still cover the corners and the drift, so it is laid out over the diagonal.
    final double side = math.sqrt(size.width * size.width + size.height * size.height) + step * 2;
    final int count = (side / step).ceil() + 2;
    final double t = clock.value;
    final Offset drift = motion == TileEmojiMotion.drift ? Offset(t * step, t * step * 2) : Offset.zero;
    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..translate(size.width / 2, size.height / 2)
      ..rotate(_tilt)
      ..translate(-side / 2, -side / 2);
    for (int row = -2; row < count; row++) {
      for (int column = -1; column < count; column++) {
        final Offset cell = Offset(column * step + (row.isOdd ? step / 2 : 0.0), row * step) + drift;
        // The emoji repeats every drift period (one column, two rows), so the loop has no jump.
        final String emoji = emojis[(column - (row / 2).floor()) % emojis.length];
        _glyphs[emoji]!.paint(canvas, cell + _sway(row, column, t));
      }
    }
    canvas.restore();
  }

  /// Each emoji floats on its own phase, like something on water; nothing for the other motions.
  Offset _sway(int row, int column, double t) {
    if (motion != TileEmojiMotion.float) return Offset.zero;
    final double phase = ((row * 7 + column * 3) % 10) / 10.0;
    final double angle = 2 * math.pi * (t * _floatCycles + phase);
    return Offset(math.cos(angle) * 0.12, math.sin(angle) * 0.18) * emojiSize;
  }

  @override
  bool shouldRepaint(_PatternPainter old) =>
      old.emojiSize != emojiSize || old.motion != motion || old.emojis.join() != emojis.join();
}
