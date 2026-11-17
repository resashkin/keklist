import 'package:material_ui/material_ui.dart';

/// Native Liquid Glass views are UIKit views: a see-through screen pushed over them (a story, full-screen photos)
/// still gets cut where they sit. Such screens [cover] while open, and [NativeGlassHider] hides the glass underneath.
abstract final class NativeGlassCover {
  static final ValueNotifier<int> _depth = ValueNotifier(0);

  /// Call the returned callback when the covering screen goes away.
  static VoidCallback cover() {
    _depth.value++;
    bool isDone = false;
    return () {
      if (isDone) return;
      isDone = true;
      _depth.value--;
    };
  }
}

/// Keeps its native glass child, laid out but not drawn, while a screen opened after it covers it.
final class NativeGlassHider extends StatefulWidget {
  final Widget child;

  const NativeGlassHider({super.key, required this.child});

  @override
  State<NativeGlassHider> createState() => _NativeGlassHiderState();
}

final class _NativeGlassHiderState extends State<NativeGlassHider> {
  late final int _depth = NativeGlassCover._depth.value;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: NativeGlassCover._depth,
    builder: (_, depth, child) => Visibility(
      visible: depth <= _depth,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: child!,
    ),
    child: widget.child,
  );
}
