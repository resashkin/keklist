// The bridge exists to feed plugins that still read the framework's material Theme.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy;
import 'package:material_ui/material_ui.dart';

/// Since Flutter 3.47 the app themes itself through `material_ui`, whose `Theme` is a different widget from
/// `package:flutter/material.dart`'s. Plugins still built on the framework's material (native_liquid_glass,
/// adaptive_dialog, …) found no theme above them and fell back to a light one — the white Liquid Glass tab bar in
/// dark mode. This mirrors the app theme's brightness and main colors into the framework's `Theme` for them.
final class LegacyThemeBridge extends StatelessWidget {
  final Widget child;

  const LegacyThemeBridge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return legacy.Theme(
      data: legacy.ThemeData(
        brightness: theme.brightness,
        scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
        colorScheme: legacy.ColorScheme(
          brightness: colors.brightness,
          primary: colors.primary,
          onPrimary: colors.onPrimary,
          secondary: colors.secondary,
          onSecondary: colors.onSecondary,
          error: colors.error,
          onError: colors.onError,
          surface: colors.surface,
          onSurface: colors.onSurface,
        ),
      ),
      child: child,
    );
  }
}
