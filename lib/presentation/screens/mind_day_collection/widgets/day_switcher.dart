import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:material_ui/material_ui.dart';

/// Slides the day's content out to one side and the next day in from the other; the value runs from -1 to 1.
final class DaySlideController {
  DaySlideController({required TickerProvider vsync})
    : _animation = AnimationController(
        vsync: vsync,
        lowerBound: -1.0,
        upperBound: 1.0,
        value: 0.0,
        duration: const Duration(milliseconds: 140),
      );

  final AnimationController _animation;

  Animation<double> get animation => _animation;
  bool get isSliding => _animation.isAnimating;

  /// Moving [forward] in time, the content leaves to the left and the next day comes from the right.
  Future<void> slide({required bool forward, required VoidCallback onSwap}) async {
    final double side = forward ? 1.0 : -1.0;
    await _animation.animateTo(-side, curve: Curves.easeIn);
    onSwap();
    _animation.value = side;
    await _animation.animateTo(0.0, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
  }

  void dispose() => _animation.dispose();
}

/// The day's content: follows [controller]'s slide, and a horizontal swipe with one finger steps a day.
final class DaySwipeArea extends StatefulWidget {
  final DaySlideController controller;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Widget child;

  const DaySwipeArea({
    super.key,
    required this.controller,
    required this.onPrevious,
    required this.onNext,
    required this.child,
  });

  static const double _minFlingVelocity = 300.0;
  static const double _minDistance = 80.0;
  static const double _slideFraction = 0.25;

  @override
  State<DaySwipeArea> createState() => _DaySwipeAreaState();
}

final class _DaySwipeAreaState extends State<DaySwipeArea> {
  final Set<int> _pointers = {};
  bool _wasMultiTouch = false;
  double _dragDistance = 0.0;

  void _onDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0.0;
    final bool isSwipe =
        velocity.abs() >= DaySwipeArea._minFlingVelocity || _dragDistance.abs() >= DaySwipeArea._minDistance;
    if (isSwipe && !_wasMultiTouch) {
      final double direction = velocity.abs() >= DaySwipeArea._minFlingVelocity ? velocity : _dragDistance;
      direction < 0 ? widget.onNext() : widget.onPrevious();
    }
    _dragDistance = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // A pinch that drifts sideways changes the columns, never the day.
    return Listener(
      onPointerDown: (event) {
        _pointers.add(event.pointer);
        if (_pointers.length == 1) _wasMultiTouch = false;
        if (_pointers.length > 1) _wasMultiTouch = true;
      },
      onPointerUp: (event) => _pointers.remove(event.pointer),
      onPointerCancel: (event) => _pointers.remove(event.pointer),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) => _dragDistance = 0.0,
        onHorizontalDragUpdate: (details) => _dragDistance += details.primaryDelta ?? 0.0,
        onHorizontalDragEnd: _onDragEnd,
        child: AnimatedBuilder(
          animation: widget.controller.animation,
          builder: (context, child) {
            final double value = widget.controller.animation.value;
            return FractionalTranslation(
              translation: Offset(value * DaySwipeArea._slideFraction, 0.0),
              child: Opacity(opacity: 1.0 - value.abs(), child: child),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// The date in the day's title bubble between a previous-day and a next-day chevron; the date slides with the day.
final class DaySwitcherTitle extends StatefulWidget {
  final int dayIndex;
  final Widget title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const DaySwitcherTitle({
    super.key,
    required this.dayIndex,
    required this.title,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  State<DaySwitcherTitle> createState() => _DaySwitcherTitleState();
}

final class _DaySwitcherTitleState extends State<DaySwitcherTitle> {
  late int _previousDayIndex = widget.dayIndex;
  bool _isForward = true;

  @override
  void didUpdateWidget(DaySwitcherTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dayIndex != widget.dayIndex) {
      _isForward = widget.dayIndex > _previousDayIndex;
      _previousDayIndex = widget.dayIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Chevron(icon: Icons.chevron_left_rounded, tooltip: context.l10n.previousDay, onTap: widget.onPrevious),
        ClipRect(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (current, previous) => Stack(alignment: Alignment.center, children: [...previous, ?current]),
            transitionBuilder: (child, animation) {
              final bool isIncoming = child.key == ValueKey(widget.dayIndex);
              final double side = (_isForward == isIncoming) ? 1.0 : -1.0;
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(begin: Offset(side * 0.5, 0.0), end: Offset.zero).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(key: ValueKey(widget.dayIndex), child: widget.title),
          ),
        ),
        _Chevron(icon: Icons.chevron_right_rounded, tooltip: context.l10n.nextDay, onTap: widget.onNext),
      ],
    );
  }
}

final class _Chevron extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _Chevron({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 20.0,
        child: SizedBox(
          width: 36.0,
          height: 44.0,
          child: Icon(icon, size: 22.0, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}
