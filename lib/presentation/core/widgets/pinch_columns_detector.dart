import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/haptics/tweak_haptics.dart';
import 'package:material_ui/material_ui.dart';

/// Two-finger pinch over a grid: spreading shows fewer, larger columns; pinching shows more.
/// While two fingers are down [builder] gets `isPinching` so the list can stop scrolling. With the live zoom of
/// [GridResizeAnimation.zoom] the grid scales with the fingers and the column count changes on release;
/// otherwise it changes step by step during the pinch. A raw [Listener] stays out of the gesture arena.
final class PinchColumnsDetector extends StatefulWidget {
  static const double _stepRatio = 1.3;

  final int columnCount;
  final ValueChanged<int> onChanged;
  final Widget Function(BuildContext context, bool isPinching) builder;

  const PinchColumnsDetector({super.key, required this.columnCount, required this.onChanged, required this.builder});

  @override
  State<PinchColumnsDetector> createState() => _PinchColumnsDetectorState();
}

final class _PinchColumnsDetectorState extends State<PinchColumnsDetector> {
  final Map<int, Offset> _pointers = {};
  double? _baseDistance;
  double? _zoomStartDistance;
  int? _pinchColumnCount;
  double _zoom = 1.0;
  Offset _focalPoint = Offset.zero;

  bool get _isPinching => _pointers.length >= 2;

  bool get _isLiveZoom {
    final SettingsState state = context.read<SettingsBloc>().state;
    return state is SettingsDataState &&
        state.settings.gridResizeAnimation == GridResizeAnimation.zoom &&
        !MediaQuery.disableAnimationsOf(context);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (event) => _update(event.pointer, event.localPosition),
    onPointerMove: (event) => _update(event.pointer, event.localPosition),
    onPointerUp: (event) => _remove(event.pointer),
    onPointerCancel: (event) => _remove(event.pointer),
    child: LayoutBuilder(
      builder: (context, constraints) => AnimatedScale(
        scale: _zoom,
        duration: _isPinching ? Duration.zero : const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: constraints.biggest.isEmpty || !constraints.biggest.isFinite
            ? Alignment.center
            : Alignment(_focalPoint.dx / constraints.maxWidth * 2 - 1, _focalPoint.dy / constraints.maxHeight * 2 - 1),
        child: widget.builder(context, _isPinching),
      ),
    ),
  );

  void _update(int pointer, Offset position) {
    final bool wasPinching = _isPinching;
    _pointers[pointer] = position;
    if (_pointers.length != 2) return;
    final Offset first = _pointers.values.first, last = _pointers.values.last;
    final double distance = (first - last).distance;
    if (!wasPinching) {
      _baseDistance = _zoomStartDistance = distance;
      _pinchColumnCount = widget.columnCount;
      setState(() => _focalPoint = (first + last) / 2);
      return;
    }
    if (_isLiveZoom) {
      final double start = _zoomStartDistance ?? distance;
      if (start > 0) setState(() => _zoom = (distance / start).clamp(0.5, 2.0));
      return;
    }
    final double? base = _baseDistance;
    if (base == null || base == 0) return;
    final double ratio = distance / base;
    final int step = ratio > PinchColumnsDetector._stepRatio
        ? -1
        : (ratio < 1 / PinchColumnsDetector._stepRatio ? 1 : 0);
    if (step == 0) return;
    _baseDistance = distance;
    _apply((_pinchColumnCount ?? widget.columnCount) + step);
  }

  void _remove(int pointer) {
    final bool wasPinching = _isPinching;
    _pointers.remove(pointer);
    if (!wasPinching || _isPinching) return;
    if (_zoom != 1.0) {
      // Each step of the ratio is one column fewer when spreading, one more when pinching.
      final int steps = (math.log(_zoom) / math.log(PinchColumnsDetector._stepRatio)).round();
      _apply(widget.columnCount - steps);
    }
    _baseDistance = _zoomStartDistance = null;
    _pinchColumnCount = null;
    setState(() => _zoom = 1.0);
  }

  void _apply(int columnCount) {
    final int current = _pinchColumnCount ?? widget.columnCount;
    final int next = columnCount.clamp(DayFeedSettings.minColumnCount, DayFeedSettings.maxColumnCount);
    if (next == current) return;
    _pinchColumnCount = next;
    tweakChangeHaptic();
    widget.onChanged(next);
  }
}
