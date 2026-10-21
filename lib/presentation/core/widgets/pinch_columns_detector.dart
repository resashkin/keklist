import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/core/haptics/tweak_haptics.dart';
import 'package:material_ui/material_ui.dart';

/// Two-finger pinch over a grid: spreading shows fewer, larger columns; pinching shows more.
/// A raw [Listener] stays out of the gesture arena, so the list keeps scrolling with one finger.
final class PinchColumnsDetector extends StatefulWidget {
  static const double _stepRatio = 1.3;

  final int columnCount;
  final ValueChanged<int> onChanged;
  final Widget child;

  const PinchColumnsDetector({super.key, required this.columnCount, required this.onChanged, required this.child});

  @override
  State<PinchColumnsDetector> createState() => _PinchColumnsDetectorState();
}

final class _PinchColumnsDetectorState extends State<PinchColumnsDetector> {
  final Map<int, Offset> _pointers = {};
  double? _baseDistance;
  int? _pinchColumnCount;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => _update(event.pointer, event.position),
      onPointerMove: (event) => _update(event.pointer, event.position),
      onPointerUp: (event) => _remove(event.pointer),
      onPointerCancel: (event) => _remove(event.pointer),
      child: widget.child,
    );
  }

  void _update(int pointer, Offset position) {
    _pointers[pointer] = position;
    if (_pointers.length != 2) return;
    final double distance = (_pointers.values.first - _pointers.values.last).distance;
    final double? base = _baseDistance;
    if (base == null || base == 0) {
      _baseDistance = distance;
      _pinchColumnCount = widget.columnCount;
      return;
    }
    final double ratio = distance / base;
    final int step = ratio > PinchColumnsDetector._stepRatio ? -1 : (ratio < 1 / PinchColumnsDetector._stepRatio ? 1 : 0);
    if (step == 0) return;
    _baseDistance = distance;
    final int current = _pinchColumnCount ?? widget.columnCount;
    final int next = (current + step).clamp(DayFeedSettings.minColumnCount, DayFeedSettings.maxColumnCount);
    if (next == current) return;
    _pinchColumnCount = next;
    tweakChangeHaptic();
    widget.onChanged(next);
  }

  void _remove(int pointer) {
    _pointers.remove(pointer);
    if (_pointers.length < 2) {
      _baseDistance = null;
      _pinchColumnCount = null;
    }
  }
}
