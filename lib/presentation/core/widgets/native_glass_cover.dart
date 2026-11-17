import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// Native Liquid Glass views are UIKit views: a see-through screen pushed over them (a story, full-screen photos)
/// still gets cut where they sit. Such a screen wraps itself in a [NativeGlassCover], and every [NativeGlassHider]
/// below it hides its glass until the screen goes away.
final class NativeGlassCover extends StatefulWidget {
  static int _count = 0;
  static final ValueNotifier<int> _depth = ValueNotifier(0);

  final Widget child;

  const NativeGlassCover({super.key, required this.child});

  static int _levelOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_CoverLevel>()?.level ?? 0;

  @override
  State<NativeGlassCover> createState() => _NativeGlassCoverState();
}

final class _NativeGlassCoverState extends State<NativeGlassCover> {
  late final int _level;

  @override
  void initState() {
    super.initState();
    _level = ++NativeGlassCover._count;
    _publish();
  }

  @override
  void dispose() {
    NativeGlassCover._count--;
    _publish();
    super.dispose();
  }

  /// Mounting and unmounting happen while the tree is locked, so listeners hear about it after the frame.
  static void _publish() => scheduleMicrotask(() => NativeGlassCover._depth.value = NativeGlassCover._count);

  @override
  Widget build(BuildContext context) => _CoverLevel(level: _level, child: widget.child);
}

final class _CoverLevel extends InheritedWidget {
  final int level;

  const _CoverLevel({required this.level, required super.child});

  @override
  bool updateShouldNotify(_CoverLevel oldWidget) => level != oldWidget.level;
}

/// Keeps its native glass child laid out but not drawn while a [NativeGlassCover] above its own screen is open.
final class NativeGlassHider extends StatelessWidget {
  final Widget child;

  const NativeGlassHider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final int level = NativeGlassCover._levelOf(context);
    return ValueListenableBuilder<int>(
      valueListenable: NativeGlassCover._depth,
      builder: (_, depth, child) => Visibility(
        visible: depth <= level,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: child!,
      ),
      child: child,
    );
  }
}
