import 'dart:ui';

import 'package:flutter/physics.dart';
import 'package:keklist/presentation/core/haptics/tweak_haptics.dart';
import 'package:material_ui/material_ui.dart';

const double _kHeight = 44.0;
const double _kInset = 4.0;
const double _kBlurSigma = 16.0;
const SpringDescription _kSpring = SpringDescription(mass: 1.0, stiffness: 420.0, damping: 24.0);

/// A frosted segmented control whose thumb springs between segments, follows the finger and ticks on each step.
final class GlassSegmentedSwitcher<T> extends StatefulWidget {
  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;

  const GlassSegmentedSwitcher({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  State<GlassSegmentedSwitcher<T>> createState() => _GlassSegmentedSwitcherState<T>();
}

final class _GlassSegmentedSwitcherState<T> extends State<GlassSegmentedSwitcher<T>>
    with SingleTickerProviderStateMixin {
  // The thumb position in segments: 0 is the first one, 1.5 is halfway between the second and the third.
  late final AnimationController _position = AnimationController.unbounded(
    vsync: this,
    value: _selectedIndex.toDouble(),
  );
  bool _isDragging = false;
  late int _hoveredIndex = _selectedIndex;

  int get _selectedIndex => widget.values.indexOf(widget.selected).clamp(0, widget.values.length - 1);
  int get _lastIndex => widget.values.length - 1;

  @override
  void didUpdateWidget(GlassSegmentedSwitcher<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && oldWidget.selected != widget.selected) _springTo(_selectedIndex);
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  void _springTo(int index) {
    _hoveredIndex = index;
    _position.animateWith(SpringSimulation(_kSpring, _position.value, index.toDouble(), _position.velocity));
  }

  void _select(int index) {
    if (index != _hoveredIndex) tweakChangeHaptic();
    _springTo(index);
    if (index != _selectedIndex) widget.onChanged(widget.values[index]);
  }

  void _moveThumb(double position) {
    _position.value = position.clamp(0.0, _lastIndex.toDouble());
    final int nearest = _position.value.round();
    if (nearest == _hoveredIndex) return;
    tweakChangeHaptic();
    setState(() => _hoveredIndex = nearest);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final BorderRadius radius = BorderRadius.circular(_kHeight / 2);
    return LayoutBuilder(
      builder: (context, constraints) {
        final double segmentWidth = (constraints.maxWidth - _kInset * 2) / widget.values.length;
        double segmentAt(double dx) => (dx - _kInset) / segmentWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => _select(segmentAt(details.localPosition.dx).floor().clamp(0, _lastIndex)),
          onHorizontalDragStart: (details) {
            _position.stop();
            setState(() => _isDragging = true);
          },
          onHorizontalDragUpdate: (details) => _moveThumb(segmentAt(details.localPosition.dx) - 0.5),
          onHorizontalDragEnd: (details) {
            setState(() => _isDragging = false);
            _select(_position.value.round());
          },
          onHorizontalDragCancel: () {
            setState(() => _isDragging = false);
            _select(_position.value.round());
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08), blurRadius: 16.0)],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _kBlurSigma, sigmaY: _kBlurSigma),
                child: Container(
                  height: _kHeight,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.45 : 0.6),
                    borderRadius: radius,
                    border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.7)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: _kInset,
                        top: _kInset,
                        bottom: _kInset,
                        width: segmentWidth,
                        child: AnimatedBuilder(
                          animation: _position,
                          builder: (context, child) =>
                              Transform.translate(offset: Offset(_position.value * segmentWidth, 0.0), child: child),
                          child: AnimatedScale(
                            scale: _isDragging ? 1.06 : 1.0,
                            duration: const Duration(milliseconds: 160),
                            curve: Curves.easeOutBack,
                            child: _Thumb(isDark: isDark),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const SizedBox(width: _kInset),
                          for (int index = 0; index <= _lastIndex; index++)
                            SizedBox(
                              width: segmentWidth,
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 160),
                                  style: (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
                                    fontWeight: index == _hoveredIndex ? FontWeight.w700 : FontWeight.w500,
                                    color: theme.colorScheme.onSurface.withValues(
                                      alpha: index == _hoveredIndex ? 1.0 : 0.6,
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                      child: Text(widget.labelOf(widget.values[index]), maxLines: 1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

final class _Thumb extends StatelessWidget {
  final bool isDark;

  const _Thumb({required this.isDark});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(_kHeight / 2),
      border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.2 : 0.9)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12), blurRadius: 8.0)],
    ),
  );
}
