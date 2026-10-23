import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';

final class ShakeHintToast extends StatelessWidget {
  final VoidCallback onTap;

  const ShakeHintToast({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: colors.inverseSurface,
      elevation: 6.0,
      borderRadius: BorderRadius.circular(24.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12.0,
            children: [
              _ShakingPhoneIcon(color: colors.onInverseSurface),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.shakeToCustomize,
                      style: textTheme.titleSmall?.copyWith(color: colors.onInverseSurface),
                    ),
                    Text(
                      context.l10n.shakeToCustomizeHint,
                      style: textTheme.bodySmall?.copyWith(color: colors.onInverseSurface.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.4, end: 0, curve: Curves.easeOutBack);
  }
}

final class _ShakingPhoneIcon extends StatelessWidget {
  final Color color;

  const _ShakingPhoneIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.smartphone, color: color, size: 26.0)
        .animate(onPlay: (controller) => controller.repeat())
        .shake(duration: 700.ms, hz: 5, rotation: 0.25)
        .then(delay: 900.ms)
        .effect(duration: 1.ms);
  }
}
