import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/services/insights/insights_period.dart';
import 'package:keklist/domain/services/insights/insights_report.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/insights/insights_widget_id.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_card.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_format.dart';

final class InsightsCountersCard extends StatelessWidget {
  final InsightsCardContext data;

  const InsightsCountersCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final InsightsCounters counters = data.report.counters;
    final InsightsPeriodKind kind = data.report.period.kind;
    Widget cell(InsightsComparison value, String caption) => Expanded(
      child: InsightsValue(
        value: InsightsFormat.number(context, value.value),
        caption: caption,
        footnote: InsightsFormat.comparison(context, kind, value),
      ),
    );
    return InsightsCard(
      category: InsightsCategory.summary,
      title: context.l10n.insightsCounters,
      trailing: InsightsFormat.periodTitle(context, kind),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.0,
        children: [
          cell(counters.minds, context.l10n.insightsMinds),
          cell(counters.activeDays, context.l10n.insightsActiveDays),
          cell(counters.words, context.l10n.insightsWords),
        ],
      ),
    );
  }
}

final class InsightsBrightestCard extends StatelessWidget {
  final InsightsCardContext data;

  const InsightsBrightestCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final BrightestSegment? brightest = data.report.brightest;
    final InsightsPeriodKind kind = data.report.period.kind;
    final String title = switch (kind) {
      InsightsPeriodKind.week => context.l10n.insightsBrightestDay,
      InsightsPeriodKind.month => context.l10n.insightsBrightestWeek,
      InsightsPeriodKind.year => context.l10n.insightsBrightestMonth,
      InsightsPeriodKind.allTime => context.l10n.insightsBrightestYear,
    };
    if (brightest == null) {
      return InsightsCard(
        category: InsightsCategory.summary,
        title: title,
        child: InsightsEmptyHint(context.l10n.insightsEmptyPeriod),
      );
    }
    final List<String> emojis = brightest.mindIds
        .expand((id) => data.mindById[id]?.emotionIds ?? const <String>[])
        .map(data.emojiOf)
        .where((emoji) => emoji.isNotEmpty)
        .toSet()
        .toList();
    return InsightsCard(
      category: InsightsCategory.summary,
      title: title,
      onTap: brightest.mindIds.isEmpty ? null : () => data.openMinds(brightest.mindIds),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4.0,
        children: [
          Text(
            InsightsFormat.segment(context, kind, brightest.range),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            context.l10n.insightsBrightestDetails(
              InsightsFormat.number(context, brightest.mindCount),
              InsightsFormat.number(context, brightest.emotionCount),
              InsightsFormat.number(context, brightest.mediaCount),
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          if (emojis.isNotEmpty) Text(emojis.join(' '), style: const TextStyle(fontSize: 22.0)),
        ],
      ),
    );
  }
}
