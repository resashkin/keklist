import 'package:material_ui/material_ui.dart';

/// A capsule button drawn as liquid glass: a light top-lit fill, a bright rim and a soft shadow. It draws the
/// glass itself rather than blurring, so it stays cheap in long lists and works on every platform.
final class GlassCapsuleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double height;
  final bool isExpanded;

  const GlassCapsuleButton({
    super.key,
    required this.child,
    required this.onTap,
    this.height = 34.0,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final BorderRadius radius = BorderRadius.circular(height / 2);
    final Widget button = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(colors.surface, Colors.white, isDark ? 0.14 : 1.0)!.withValues(alpha: 0.9),
            Color.lerp(colors.surface, colors.onSurface, isDark ? 0.04 : 0.05)!.withValues(alpha: 0.9),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 12.0,
            offset: const Offset(0.0, 3.0),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: height / 2 + 1.0),
              child: Center(
                widthFactor: isExpanded ? null : 1.0,
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: colors.onSurface.withValues(alpha: 0.85), fontWeight: FontWeight.w600),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return AnimatedOpacity(
      opacity: onTap == null ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: isExpanded ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
