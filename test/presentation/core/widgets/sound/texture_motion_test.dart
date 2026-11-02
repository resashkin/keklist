import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/core/widgets/sound/animated_emotion_texture.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const Size step = Size(100, 40);

  test('silence keeps every animation still', () {
    for (final StoryTextureAnimation animation in StoryTextureAnimation.values) {
      final motion = textureCellMotion(animation: animation, level: 0.0, time: 3.2, row: 2, column: 5, step: step);
      expect(motion.offset, Offset.zero, reason: animation.name);
      expect(motion.scale, 1.0, reason: animation.name);
    }
  });

  test('pulse grows with loudness', () {
    final quiet = textureCellMotion(
      animation: StoryTextureAnimation.pulse,
      level: 0.2,
      time: 0,
      row: 0,
      column: 0,
      step: step,
    );
    final loud = textureCellMotion(
      animation: StoryTextureAnimation.pulse,
      level: 1.0,
      time: 0,
      row: 0,
      column: 0,
      step: step,
    );
    expect(loud.scale, greaterThan(quiet.scale));
  });

  test('equalizer only bounces upwards', () {
    for (int column = 0; column < 10; column++) {
      final motion = textureCellMotion(
        animation: StoryTextureAnimation.equalizer,
        level: 1.0,
        time: 0.4,
        row: 0,
        column: column,
        step: step,
      );
      expect(motion.offset.dy, lessThanOrEqualTo(0.0));
    }
  });
}
