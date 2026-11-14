import 'package:material_ui/material_ui.dart';

/// Shows [child] the screen as if the keyboard were hidden.
///
/// While the keyboard slides in, the bottom view inset changes on every frame, and everything under a
/// `MediaQuery` that depends on it rebuilds each time. Screens whose own content has no text field (the tabs: their
/// fields live in sheets and pushed pages) don't need to follow the keyboard, so this keeps their `MediaQuery`
/// unchanged and only this widget rebuilds. See `documentation/DEFERRED_AUTOFOCUS.md`.
final class KeyboardInsetsBarrier extends StatelessWidget {
  final Widget child;

  const KeyboardInsetsBarrier({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(
        viewInsets: data.viewInsets.copyWith(bottom: 0.0),
        padding: data.padding.copyWith(bottom: data.viewPadding.bottom),
      ),
      child: child,
    );
  }
}
