import 'dart:ui';

import 'package:material_ui/material_ui.dart';

const double _kBarHeight = 52.0;
const double _kBubbleHeight = 44.0;
const double _kBlurSigma = 16.0;

/// A see-through top bar in the spirit of iOS 26: no bar background, the title and the actions
/// float as frosted bubbles. Pair with `Scaffold.extendBodyBehindAppBar` and pad lists by
/// `MediaQuery.paddingOf(context).top` so content scrolls under the bubbles.
final class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final VoidCallback? onTitleTap;
  final VoidCallback? onTitleLongPress;
  final List<GlassBarAction> actions;
  final bool centerTitle;

  const GlassAppBar({
    super.key,
    required this.title,
    this.onTitleTap,
    this.onTitleLongPress,
    this.actions = const [],
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(_kBarHeight);

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = ModalRoute.of(context)?.impliesAppBarDismissal ?? false;
    final Widget titleBubble = GestureDetector(
      onTap: onTitleTap,
      onLongPress: onTitleLongPress,
      child: GlassBubble(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          child: title,
        ),
      ),
    );
    final Widget? actionsBubble = actions.isEmpty
        ? null
        : GlassBubble(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final GlassBarAction action in actions)
                  IconButton(
                    tooltip: action.tooltip,
                    icon: Icon(action.icon),
                    onPressed: action.onPressed,
                    onLongPress: action.onLongPress,
                  ),
              ],
            ),
          );
    final Widget? backBubble = canGoBack
        ? GlassBubble(
            child: IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20.0),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          )
        : null;

    final Color background = Theme.of(context).scaffoldBackgroundColor;
    // Fades content out under the status bar, where nothing is meant to be read.
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [background, background.withValues(alpha: 0.85), background.withValues(alpha: 0.0)],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _kBarHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: centerTitle
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      if (backBubble != null) Align(alignment: Alignment.centerLeft, child: backBubble),
                      titleBubble,
                      if (actionsBubble != null) Align(alignment: Alignment.centerRight, child: actionsBubble),
                    ],
                  )
                : Row(
                    spacing: 8.0,
                    children: [
                      ?backBubble,
                      Flexible(
                        child: Align(alignment: Alignment.centerLeft, child: titleBubble),
                      ),
                      ?actionsBubble,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

final class GlassBarAction {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  const GlassBarAction({required this.icon, this.tooltip, this.onPressed, this.onLongPress});
}

/// A frosted, rounded bubble: blurred backdrop, translucent surface, hairline border and a soft shadow.
final class GlassBubble extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassBubble({super.key, required this.child, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_kBubbleHeight / 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08), blurRadius: 16.0)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_kBubbleHeight / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _kBlurSigma, sigmaY: _kBlurSigma),
          child: Container(
            height: _kBubbleHeight,
            padding: padding,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: isDark ? 0.45 : 0.6),
              borderRadius: BorderRadius.circular(_kBubbleHeight / 2),
              border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.7)),
            ),
            child: Center(widthFactor: 1.0, child: child),
          ),
        ),
      ),
    );
  }
}
