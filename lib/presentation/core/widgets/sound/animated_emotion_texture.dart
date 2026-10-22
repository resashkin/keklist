import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_playback.dart';
import 'package:material_ui/material_ui.dart';

const double _kAngle = -math.pi / 12;
const double _kLevelSmoothing = 0.25;
const double _kDriftBaseSpeed = 6.0;
const double _kDriftLoudSpeed = 140.0;

/// The offset and scale of one texture cell at [time] seconds for the current sound [level].
({Offset offset, double scale}) textureCellMotion({
  required StoryTextureAnimation animation,
  required double level,
  required double time,
  required int row,
  required int column,
  required Size step,
}) => switch (animation) {
  StoryTextureAnimation.pulse => (
    offset: Offset.zero,
    scale: 1.0 + 0.6 * level * (0.75 + 0.25 * math.sin(time * 6.0 + (row + column) * 0.9)),
  ),
  StoryTextureAnimation.wave => (
    offset: Offset(0.0, math.sin(column * 0.7 + row * 0.3 + time * 4.0) * step.height * 0.45 * level),
    scale: 1.0,
  ),
  StoryTextureAnimation.equalizer => (
    offset: Offset(0.0, -(math.sin(column * 1.3 + time * 9.0).abs()) * step.height * 0.8 * level),
    scale: 1.0 + 0.15 * level,
  ),
  StoryTextureAnimation.off ||
  StoryTextureAnimation.drift ||
  StoryTextureAnimation.glow => (offset: Offset.zero, scale: 1.0),
};

/// "😄 Joy" labels of the mind's emotions tiled behind a story or viewer page; moves with the sound that
/// [SoundPlaybackScope] reports, the way the shake sheet picked. Nothing is drawn for a mind without emotions.
final class AnimatedEmotionTexture extends StatefulWidget {
  final Mind mind;
  final Color color;
  final double opacity;

  const AnimatedEmotionTexture({super.key, required this.mind, required this.color, this.opacity = 0.14});

  @override
  State<AnimatedEmotionTexture> createState() => _AnimatedEmotionTextureState();
}

final class _AnimatedEmotionTextureState extends State<AnimatedEmotionTexture> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  final _TextureMotion _motion = _TextureMotion();
  SoundPlayback? _playback;
  Duration _lastElapsed = Duration.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playback = SoundPlaybackScope.watch(context);
    if (!_ticker.isActive) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _motion.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final double dt = (elapsed - _lastElapsed).inMicroseconds / Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;
    _motion.advance(dt: dt, target: _playback?.level ?? 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mind.emotionIds.isEmpty) return const SizedBox.shrink();
    final StoryTextureAnimation animation = context.select<SettingsBloc, StoryTextureAnimation>(
      (bloc) => bloc.state is SettingsDataState
          ? (bloc.state as SettingsDataState).settings.storyTextureAnimation
          : StoryTextureAnimation.pulse,
    );
    return BlocBuilder<EmotionBloc, EmotionState>(
      builder: (context, state) {
        if (state is! EmotionsList) return const SizedBox.shrink();
        final List<Emotion> emotions = widget.mind.emotionIds.map(state.byId).whereType<Emotion>().toList();
        if (emotions.isEmpty) return const SizedBox.shrink();
        return IgnorePointer(
          child: ExcludeSemantics(
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: _TexturePainter(
                  labels: [for (final Emotion emotion in emotions) '${emotion.emoji} ${emotion.title}'],
                  color: widget.color,
                  opacity: widget.opacity,
                  animation: animation,
                  motion: _motion,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Smoothed loudness plus the running clocks the animations read; notifies on every frame.
final class _TextureMotion extends ChangeNotifier {
  double level = 0.0;
  double time = 0.0;
  double drift = 0.0;

  void advance({required double dt, required double target}) {
    final double previous = level;
    level += (target - level) * _kLevelSmoothing;
    if (level < 0.001 && previous < 0.001) return;
    time += dt;
    drift += dt * (_kDriftBaseSpeed + _kDriftLoudSpeed * level);
    notifyListeners();
  }
}

final class _TexturePainter extends CustomPainter {
  final List<String> labels;
  final Color color;
  final double opacity;
  final StoryTextureAnimation animation;
  final _TextureMotion motion;
  final List<TextPainter> _painters;

  _TexturePainter({
    required this.labels,
    required this.color,
    required this.opacity,
    required this.animation,
    required this.motion,
  }) : _painters = [
         for (final String label in labels)
           TextPainter(
             text: TextSpan(
               text: label,
               style: TextStyle(color: color, fontSize: 18.0, fontWeight: FontWeight.w600),
             ),
             textDirection: TextDirection.ltr,
           )..layout(),
       ],
       super(repaint: motion);

  @override
  void paint(Canvas canvas, Size size) {
    if (_painters.isEmpty) return;
    final double level = animation == StoryTextureAnimation.off ? 0.0 : motion.level;
    final double labelWidth = _painters.map((painter) => painter.width).reduce(math.max);
    final Size step = Size(labelWidth + 28.0, _painters.first.height * 2.2);
    final double side = math.sqrt(size.width * size.width + size.height * size.height);
    final int columns = (side / step.width).ceil() + 2;
    final int rows = (side / step.height).ceil() + 2;
    final double drift = animation == StoryTextureAnimation.drift ? motion.drift % step.width : 0.0;

    final bool isGlow = animation == StoryTextureAnimation.glow;
    final double alpha = (isGlow ? opacity * (0.6 + 1.6 * level) : opacity).clamp(0.0, 1.0);
    final double blur = isGlow ? (1.0 - level) * 3.0 : 0.0;
    canvas.clipRect(Offset.zero & size);
    canvas.saveLayer(
      Offset.zero & size,
      Paint()
        ..color = Color.fromRGBO(0, 0, 0, alpha)
        ..imageFilter = blur > 0.05 ? ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur) : null,
    );
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(_kAngle);
    int labelIndex = 0;
    for (int row = 0; row < rows; row++) {
      final double rowShift = row.isOdd ? step.width / 2 : 0.0;
      for (int column = 0; column < columns; column++) {
        final TextPainter painter = _painters[labelIndex++ % _painters.length];
        final ({Offset offset, double scale}) cell = textureCellMotion(
          animation: animation,
          level: level,
          time: motion.time,
          row: row,
          column: column,
          step: step,
        );
        final Offset center = Offset(
          -side / 2 + column * step.width + rowShift + drift - step.width,
          -side / 2 + row * step.height,
        );
        canvas.save();
        canvas.translate(center.dx + cell.offset.dx, center.dy + cell.offset.dy);
        canvas.scale(cell.scale);
        painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
        canvas.restore();
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TexturePainter oldDelegate) =>
      oldDelegate.labels.join() != labels.join() ||
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity ||
      oldDelegate.animation != animation;
}
