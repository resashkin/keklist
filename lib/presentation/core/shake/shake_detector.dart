import 'dart:math' as math;

final class ShakeDetector {
  static const double _earthGravity = 9.80665;

  final double thresholdGravity;
  final int requiredPeakCount;
  final Duration peakWindow;
  final Duration cooldown;

  final List<DateTime> _peakTimestamps = [];
  DateTime? _lastShakeTimestamp;
  bool _isAboveThreshold = false;

  /// A real back-and-forth shake: three separate strong peaks within a second, so a bump or a phone put down
  /// on a table doesn't count.
  ShakeDetector({
    this.thresholdGravity = 3.0,
    this.requiredPeakCount = 3,
    this.peakWindow = const Duration(milliseconds: 1000),
    this.cooldown = const Duration(milliseconds: 1500),
  });

  bool addReading({required double x, required double y, required double z, required DateTime timestamp}) {
    final bool wasAboveThreshold = _isAboveThreshold;
    _isAboveThreshold = gForce(x: x, y: y, z: z) >= thresholdGravity;
    // A peak counts once, however many readings it spans, until the force drops below the threshold again.
    if (!_isAboveThreshold || wasAboveThreshold || _isCoolingDown(timestamp)) return false;

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
