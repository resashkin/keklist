import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/blocs/emotion_bloc/emotion_bloc.dart';
import 'package:keklist/presentation/core/extensions/story_settings_extension.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_playback.dart';
import 'package:material_ui/material_ui.dart';

const double _kLevelSmoothing = 0.25;
const double _kDriftLoudSpeed = 40.0;

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

/// A few "😄 Joy" labels of the mind's emotions floating behind a story like clouds: three layers, the far one
/// smaller, paler, softer and slower, all drifting very slowly sideways and wrapping around. They react to the sound
/// that [SoundPlaybackScope] reports, the way the shake sheet picked. Nothing is drawn for a mind without emotions.
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
    final StorySettings story = context.watchStorySettings();
    _motion.sensitivity = story.sensitivity;
    _motion.isStill = MediaQuery.disableAnimationsOf(context);
    final StoryTextureAnimation animation = story.textureAnimation;
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
                  seed: _seedOf(widget.mind.id),
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

/// A stable seed per mind, so its clouds keep their places every time the story opens.
int _seedOf(String id) => id.codeUnits.fold(17, (hash, unit) => (hash * 31 + unit) & 0x7fffffff);

/// One floating label: its layer (0 is the farthest), which emotion it shows and where it starts.
typedef _Cloud = ({int layer, int label, double x, double y, double phase});

/// Clouds per layer, from the farthest; together they stay sparse, about nine on a phone screen.
const List<int> _kCloudsPerLayer = [3, 3, 3];
const List<double> _kLayerScale = [0.8, 1.0, 1.25];
const List<double> _kLayerAlpha = [0.45, 0.7, 1.0];
const List<double> _kLayerBlur = [1.6, 0.6, 0.0];
// Points per second: a cloud needs about a minute to cross the screen.
const List<double> _kLayerSpeed = [4.0, 6.0, 9.0];

/// Places the clouds: each takes its own horizontal band, so they never pile up, and a random spot along it.
List<_Cloud> _cloudsFor({required int seed, required int labelCount}) {
  final math.Random random = math.Random(seed);
  final int total = _kCloudsPerLayer.fold(0, (sum, count) => sum + count);
  final List<int> bands = List<int>.generate(total, (index) => index)..shuffle(random);
  final List<_Cloud> clouds = [];
  for (int layer = 0; layer < _kCloudsPerLayer.length; layer++) {
    for (int index = 0; index < _kCloudsPerLayer[layer]; index++) {
      final int band = bands[clouds.length];
      clouds.add((
        layer: layer,
        label: clouds.length % labelCount,
        x: random.nextDouble(),
        y: (band + 0.2 + 0.6 * random.nextDouble()) / total,
        phase: random.nextDouble() * 2 * math.pi,
      ));
    }
  }
  return clouds;
}

/// Smoothed loudness plus the running clocks the animations read; notifies on every frame.
final class _TextureMotion extends ChangeNotifier {
  double level = 0.0;
  double time = 0.0;
  double drift = 0.0;
  double sensitivity = 1.0;
  bool isStill = false;

  void advance({required double dt, required double target}) {
    level += ((target * sensitivity).clamp(0.0, 1.0) - level) * _kLevelSmoothing;
    if (isStill) return;
    // The clouds always float; loud sound only adds to the drift clock.
    time += dt;
    drift += dt * _kDriftLoudSpeed * level;
    notifyListeners();
  }
}

final class _TexturePainter extends CustomPainter {
  final int seed;
  final List<String> labels;
  final Color color;
  final double opacity;
  final StoryTextureAnimation animation;
  final _TextureMotion motion;
  final List<TextPainter> _painters;
  final List<_Cloud> _clouds;

  _TexturePainter({
    required this.seed,
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
       _clouds = _cloudsFor(seed: seed, labelCount: labels.length),
       super(repaint: motion);

  @override
  void paint(Canvas canvas, Size size) {
    if (_painters.isEmpty) return;
    final double level = animation == StoryTextureAnimation.off ? 0.0 : motion.level;
    final bool isGlow = animation == StoryTextureAnimation.glow;
    final double alpha = (isGlow ? opacity * (0.6 + 1.6 * level) : opacity).clamp(0.0, 1.0);
    final double glowBlur = isGlow ? (1.0 - level) * 3.0 : 0.0;
    final double drift = animation == StoryTextureAnimation.drift ? motion.drift : 0.0;
    final double labelWidth = _painters.map((painter) => painter.width).reduce(math.max);
    canvas.clipRect(Offset.zero & size);
    for (int layer = 0; layer < _kCloudsPerLayer.length; layer++) {
      final double blur = _kLayerBlur[layer] + glowBlur;
      canvas.saveLayer(
        Offset.zero & size,
        Paint()
          ..color = Color.fromRGBO(0, 0, 0, alpha * _kLayerAlpha[layer])
          ..imageFilter = blur > 0.05 ? ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur) : null,
      );
      final double layerScale = _kLayerScale[layer];
      // A cloud leaves on the right and comes back from the left once it is fully out of sight.
      final double span = size.width + labelWidth * layerScale * 1.6;
      int column = 0;
      for (final _Cloud cloud in _clouds.where((cloud) => cloud.layer == layer)) {
        final TextPainter painter = _painters[cloud.label];
        final ({Offset offset, double scale}) cell = textureCellMotion(
          animation: animation,
          level: level,
          time: motion.time,
          row: layer,
          column: column++,
          step: Size(painter.width, painter.height * 2.2),
        );
        final double travelled = cloud.x * span + (motion.time + drift / 10.0) * _kLayerSpeed[layer];
        final Offset center = Offset(
          travelled % span - labelWidth * layerScale * 0.8,
          cloud.y * size.height + math.sin(motion.time * 0.3 + cloud.phase) * 4.0,
        );
        canvas.save();
        canvas.translate(center.dx + cell.offset.dx, center.dy + cell.offset.dy);
        canvas.scale(layerScale * cell.scale);
        painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
        canvas.restore();
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_TexturePainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.labels.join() != labels.join() ||
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity ||
      oldDelegate.animation != animation;
}
