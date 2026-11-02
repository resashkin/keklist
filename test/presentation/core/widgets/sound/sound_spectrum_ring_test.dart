import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/presentation/core/widgets/sound/sound_spectrum_ring.dart';

void main() {
  test('silence draws no rays', () {
    for (int index = 0; index < 56; index++) {
      expect(spectrumRayLength(index: index, count: 56, level: 0.0, time: 1.3), 0.0);
    }
  });

  test('rays stay within the level and vary around the ring', () {
    final List<double> lengths = [
      for (int index = 0; index < 56; index++) spectrumRayLength(index: index, count: 56, level: 0.8, time: 0.7),
    ];
    expect(lengths.every((length) => length >= 0.8 * 0.35 - 1e-9 && length <= 0.8 + 1e-9), isTrue);
    expect(lengths.toSet().length, greaterThan(10));
  });
}
