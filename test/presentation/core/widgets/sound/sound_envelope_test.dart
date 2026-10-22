import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_envelope.dart';

void main() {
  test('normalizes to the loud parts of the file', () {
    final SoundEnvelope envelope = SoundEnvelope.fromRaw([0, 50, 100, 100, 100]);
    expect(envelope.levels.first, 0.0);
    expect(envelope.levels[1], closeTo(0.5, 0.001));
    expect(envelope.levels.last, 1.0);
  });

  test('silence stays silent', () {
    expect(SoundEnvelope.fromRaw([0, 0, 0]).levels, [0.0, 0.0, 0.0]);
  });

  test('interpolates between levels and clamps past the end', () {
    const SoundEnvelope envelope = SoundEnvelope([0.0, 1.0]);
    final Duration half = Duration(microseconds: Duration.microsecondsPerSecond ~/ SoundEnvelope.levelsPerSecond ~/ 2);
    expect(envelope.levelAt(half), closeTo(0.5, 0.01));
    expect(envelope.levelAt(const Duration(minutes: 5)), 1.0);
  });
}
