import 'dart:math' as math;

final class ShakeDetector {
  static const double _earthGravity = 9.80665;

  final double thresholdGravity;
  final int requiredPeakCount;
  final Duration peakWindow;
  final Duration cooldown;

  final List<DateTime> _peakTimestamps = [];
  DateTime? _lastShakeTimestamp;

  ShakeDetector({
    this.thresholdGravity = 2.7,
    this.requiredPeakCount = 2,
    this.peakWindow = const Duration(milliseconds: 800),
    this.cooldown = const Duration(milliseconds: 1500),
  });

  bool addReading({required double x, required double y, required double z, required DateTime timestamp}) {
    if (_isCoolingDown(timestamp)) return false;
    if (gForce(x: x, y: y, z: z) < thresholdGravity) return false;

    _peakTimestamps
      ..add(timestamp)
      ..removeWhere((peak) => timestamp.difference(peak) > peakWindow);
    if (_peakTimestamps.length < requiredPeakCount) return false;

    _peakTimestamps.clear();
    _lastShakeTimestamp = timestamp;
    return true;
  }

  bool _isCoolingDown(DateTime timestamp) {
    final DateTime? lastShake = _lastShakeTimestamp;
    return lastShake != null && timestamp.difference(lastShake) < cooldown;
  }

  static double gForce({required double x, required double y, required double z}) =>
      math.sqrt(x * x + y * y + z * z) / _earthGravity;
}
