import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/presentation/core/shake/shake_detector.dart';

void main() {
  const double strongAcceleration = 32.0;
  const double restingAcceleration = 9.81;
  final DateTime start = DateTime(2026, 1, 1);
  DateTime at(int milliseconds) => start.add(Duration(milliseconds: milliseconds));

  bool feed(ShakeDetector detector, double x, int milliseconds) =>
      detector.addReading(x: x, y: 0, z: 0, timestamp: at(milliseconds));

  // One swing: a strong reading, then the force falls back.
  bool peak(ShakeDetector detector, int milliseconds) {
    final bool isShake = feed(detector, strongAcceleration, milliseconds);
    feed(detector, restingAcceleration, milliseconds + 20);
    return isShake;
  }

  group('gForce', () {
    test('resting phone is about 1 g', () {
      expect(ShakeDetector.gForce(x: 0, y: 0, z: restingAcceleration), closeTo(1.0, 0.01));
    });

    test('combines all axes', () {
      expect(ShakeDetector.gForce(x: 3, y: 4, z: 0), closeTo(5 / 9.80665, 0.0001));
    });
  });

  group('addReading', () {
    test('ignores readings below threshold', () {
      final ShakeDetector detector = ShakeDetector();
      for (int i = 0; i < 20; i++) {
        expect(feed(detector, restingAcceleration * 2.5, i * 20), isFalse);
      }
    });

    test('a long jolt is a single peak, not a shake', () {
      final ShakeDetector detector = ShakeDetector();
      for (int i = 0; i < 10; i++) {
        expect(feed(detector, strongAcceleration, i * 16), isFalse);
      }
    });

    test('two peaks are not enough', () {
      final ShakeDetector detector = ShakeDetector();
      expect(peak(detector, 0), isFalse);
      expect(peak(detector, 200), isFalse);
    });

    test('three peaks within the window are a shake', () {
      final ShakeDetector detector = ShakeDetector();
      expect(peak(detector, 0), isFalse);
      expect(peak(detector, 200), isFalse);
      expect(peak(detector, 400), isTrue);
    });

    test('peaks further apart than the window are not a shake', () {
      final ShakeDetector detector = ShakeDetector(peakWindow: const Duration(milliseconds: 500));
      expect(peak(detector, 0), isFalse);
      expect(peak(detector, 300), isFalse);
      expect(peak(detector, 900), isFalse);
      expect(peak(detector, 1100), isFalse);
      expect(peak(detector, 1300), isTrue);
    });

    test('cooldown suppresses repeated shakes', () {
      final ShakeDetector detector = ShakeDetector(requiredPeakCount: 2, cooldown: const Duration(milliseconds: 1000));
      peak(detector, 0);
      expect(peak(detector, 100), isTrue);
      expect(peak(detector, 200), isFalse);
      expect(peak(detector, 300), isFalse);
      expect(peak(detector, 1200), isFalse);
      expect(peak(detector, 1300), isTrue);
    });

    test('respects custom threshold and peak count', () {
      final ShakeDetector detector = ShakeDetector(thresholdGravity: 1.5, requiredPeakCount: 2);
      expect(peak(detector, 0), isFalse);
      expect(peak(detector, 100), isTrue);
    });
  });
}
