import 'package:material_ui/material_ui.dart';

/// Draws a soft gray circle under every finger on [child] while [isEnabled], fading out on release, so screen
/// recordings show where the screen was touched. Touches still reach [child] untouched.
final class TouchIndicators extends StatefulWidget {
  final bool isEnabled;
  final Widget child;

  const TouchIndicators({super.key, required this.isEnabled, required this.child});

  static const double diameter = 44.0;
  static const Duration fadeDuration = Duration(milliseconds: 250);

  @override
  State<TouchIndicators> createState() => _TouchIndicatorsState();
}

final class _TouchIndicatorsState extends State<TouchIndicators> {
  final Map<int, Offset> _touches = {};
  final Map<int, Offset> _released = {};

  void _place(PointerEvent event) => setState(() {
    _released.remove(event.pointer);
    _touches[event.pointer] = event.localPosition;
  });

  void _release(PointerEvent event) {
    final Offset? position = _touches.remove(event.pointer);
    if (position == null) return;
    setState(() => _released[event.pointer] = position);
  }

  @override
  void didUpdateWidget(TouchIndicators oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isEnabled) {
      _touches.clear();
      _released.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Same tree either way, so switching the flag never rebuilds the app under it.
    final bool isEnabled = widget.isEnabled;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: isEnabled ? _place : null,
      onPointerMove: isEnabled ? _place : null,
      onPointerUp: isEnabled ? _release : null,
      onPointerCancel: isEnabled ? _release : null,
      child: Stack(
        textDirection: TextDirection.ltr,
        fit: StackFit.expand,
        children: [
          widget.child,
          for (final MapEntry(:key, :value) in _touches.entries) _Dot(key: ValueKey(key), position: value),
          for (final MapEntry(:key, :value) in _released.entries)
            _Dot(
              key: ValueKey(key),
              position: value,
              isFading: true,
              onFaded: () => setState(() => _released.remove(key)),
            ),
        ],
      ),
    );
  }
}

final class _Dot extends StatelessWidget {
  final Offset position;
  final bool isFading;
  final VoidCallback? onFaded;

  const _Dot({super.key, required this.position, this.isFading = false, this.onFaded});

  @override
  Widget build(BuildContext context) {
    const double radius = TouchIndicators.diameter / 2;
    return Positioned(
      left: position.dx - radius,
      top: position.dy - radius,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: isFading ? 0.0 : 1.0),
          duration: TouchIndicators.fadeDuration,
          onEnd: onFaded,
          builder: (context, opacity, child) => Opacity(
            opacity: opacity,
            child: Transform.scale(scale: 0.8 + 0.2 * opacity, child: child),
          ),
          child: Container(
            width: TouchIndicators.diameter,
            height: TouchIndicators.diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x99B0B0B0),
              border: Border.all(color: const Color(0xCCFFFFFF), width: 1.5),
              boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 6.0)],
            ),
          ),
        ),
      ),
    );
  }
}
