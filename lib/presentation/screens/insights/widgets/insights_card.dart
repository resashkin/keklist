import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/insights/insights_report.dart';
import 'package:keklist/presentation/screens/insights/insights_widget_id.dart';

/// Everything a card needs: the report, lookups and the two navigation actions.
final class InsightsCardContext {
  final InsightsReport report;
  final Map<String, Emotion> emotionById;
  final Map<String, Mind> mindById;
  final Map<String, Color> emotionColors;
  final void Function(List<String> mindIds, {int initialIndex}) openMinds;
  final void Function(int dayIndex) openDay;

  /// False where the photo library is not indexed (Android), so library counts are hidden.
  final bool hasLibraryIndex;

  const InsightsCardContext({
    required this.report,
    required this.emotionById,
    required this.mindById,
    required this.emotionColors,
    required this.openMinds,
    required this.openDay,
    required this.hasLibraryIndex,
  });

  Color colorOf(String emotionId) => emotionColors[emotionId] ?? Colors.grey;
  String emojiOf(String emotionId) => emotionById[emotionId]?.emoji ?? '';
}

/// Calm Health-style card: a small colored category header, then the content.
final class InsightsCard extends StatelessWidget {
  final InsightsCategory category;
  final String title;
  final String? trailing;
  final Widget child;
  final VoidCallback? onTap;

  const InsightsCard({
    super.key,
    required this.category,
    required this.title,
    required this.child,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(category.icon, size: 16.0, color: category.color),
                    const SizedBox(width: 6.0),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.labelLarge?.copyWith(color: category.color, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (trailing != null)
                      Text(trailing!, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
                    if (onTap != null) Icon(Icons.chevron_right, size: 18.0, color: theme.hintColor),
                  ],
                ),
                const SizedBox(height: 12.0),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One-line hint shown instead of a chart when there is nothing to show.
final class InsightsEmptyHint extends StatelessWidget {
  final String text;

  const InsightsEmptyHint(this.text, {super.key});

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor));
}

/// Big number with a small caption, Health-style.
final class InsightsValue extends StatelessWidget {
  final String value;
  final String caption;
  final String? footnote;

  const InsightsValue({super.key, required this.value, required this.caption, this.footnote});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
        Text(caption, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        if (footnote != null)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(footnote!, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
          ),
      ],
    );
  }
}

/// A horizontal proportion bar; [fraction] is clamped to 0…1.
final class InsightsBar extends StatelessWidget {
  final double fraction;
  final Color color;
  final double height;

  const InsightsBar({super.key, required this.fraction, required this.color, this.height = 8.0});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: color.withValues(alpha: 0.15)),
            FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: fraction.clamp(0.0, 1.0),
              child: ColoredBox(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
