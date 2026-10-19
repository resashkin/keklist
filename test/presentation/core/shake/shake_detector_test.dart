import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/presentation/core/shake/shake_detector.dart';

void main() {
  const double strongAcceleration = 30.0;
  const double restingAcceleration = 9.81;
  final DateTime start = DateTime(2026, 1, 1);
  DateTime at(int milliseconds) => start.add(Duration(milliseconds: milliseconds));

  bool feed(ShakeDetector detector, double x, int milliseconds) =>
      detector.addReading(x: x, y: 0, z: 0, timestamp: at(milliseconds));

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
        expect(feed(detector, restingAcceleration * 2, i * 20), isFalse);
      }
    });

    test('a single jolt is not a shake', () {
      final ShakeDetector detector = ShakeDetector();
      expect(feed(detector, strongAcceleration, 0), isFalse);
      expect(feed(detector, restingAcceleration, 20), isFalse);
    });

    test('two peaks within the window are a shake', () {
      final ShakeDetector detector = ShakeDetector();
      expect(feed(detector, strongAcceleration, 0), isFalse);
      expect(feed(detector, strongAcceleration, 300), isTrue);
    });

    test('peaks further apart than the window are not a shake', () {
      final ShakeDetector detector = ShakeDetector(peakWindow: const Duration(milliseconds: 500));
      expect(feed(detector, strongAcceleration, 0), isFalse);
      expect(feed(detector, strongAcceleration, 600), isFalse);
      expect(feed(detector, strongAcceleration, 900), isTrue);
    });

    test('cooldown suppresses repeated shakes', () {
      final ShakeDetector detector = ShakeDetector(cooldown: const Duration(milliseconds: 1000));
      feed(detector, strongAcceleration, 0);
      expect(feed(detector, strongAcceleration, 100), isTrue);
      expect(feed(detector, strongAcceleration, 200), isFalse);
      expect(feed(detector, strongAcceleration, 300), isFalse);
      expect(feed(detector, strongAcceleration, 1200), isFalse);
      expect(feed(detector, strongAcceleration, 1300), isTrue);
    });

    test('respects custom threshold and peak count', () {
      final ShakeDetector detector = ShakeDetector(thresholdGravity: 1.5, requiredPeakCount: 3);
      expect(feed(detector, 20, 0), isFalse);
      expect(feed(detector, 20, 50), isFalse);
      expect(feed(detector, 20, 100), isTrue);
    });
  });
}
