import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/insights/insights_report.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/insights/insights_widget_id.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_card.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_format.dart';

final class InsightsOnThisDayCard extends StatelessWidget {
  final InsightsCardContext data;

  const InsightsOnThisDayCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<OnThisDayGroup> groups = data.report.onThisDay;
    return InsightsCard(
      category: InsightsCategory.memories,
      title: context.l10n.insightsOnThisDay,
      child: groups.isEmpty
          ? InsightsEmptyHint(context.l10n.insightsEmptyOnThisDay)
          : Column(
              children: [
                for (final OnThisDayGroup group in groups)
                  InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () => data.openMinds(group.mindIds),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: _row(context, group),
                    ),
                  ),
              ],
            ),
    );
  }

  static String _pointTitle(BuildContext context, MemoryPoint point) => switch (point) {
    MemoryPoint.weekAgo => context.l10n.insightsWeekAgo,
    MemoryPoint.monthAgo => context.l10n.insightsMonthAgo,
    MemoryPoint.halfYearAgo => context.l10n.insightsHalfYearAgo,
    MemoryPoint.yearAgo => context.l10n.insightsYearAgo,
    MemoryPoint.twoYearsAgo => context.l10n.insightsTwoYearsAgo,
  };

  Widget _row(BuildContext context, OnThisDayGroup group) {
    final List<Mind> minds = group.mindIds.map((id) => data.mindById[id]).whereType<Mind>().toList();
    final String emojis = minds.expand((mind) => mind.emotionIds).map(data.emojiOf).toSet().join(' ');
    final String preview = minds.map((mind) => mind.plainNote.trim()).firstWhere((text) => text.isNotEmpty, orElse: () => '');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12.0,
      children: [
        SizedBox(
          width: 104.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_pointTitle(context, group.point), style: Theme.of(context).textTheme.labelLarge),
              Text(
                InsightsFormat.day(context, group.dayIndex),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (emojis.isNotEmpty) Text(emojis),
              if (preview.isNotEmpty) Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Text(
          InsightsFormat.number(context, minds.length),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }
}

final class InsightsMediaCountersCard extends StatelessWidget {
  final InsightsCardContext data;

  const InsightsMediaCountersCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final MediaInsight media = data.report.media;
    final List<(int, String)> values = [
      if (data.hasLibraryIndex) ...[
        (media.libraryPhotos, context.l10n.insightsPhotos),
        (media.libraryVideos, context.l10n.insightsVideos),
      ],
      (media.audioMinds, context.l10n.insightsVoiceNotes),
      (media.videoMinds, context.l10n.insightsRoundVideos),
    ];
    return InsightsCard(
      category: InsightsCategory.media,
      title: context.l10n.insightsMediaCounters,
      trailing: InsightsFormat.periodTitle(context, data.report.period.kind),
      // One square tile per kind, so every count and caption lines up however long the caption is.
      child: Row(
        spacing: 8.0,
        children: [
          for (final (int value, String caption) in values)
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: _MediaCountTile(value: InsightsFormat.number(context, value), caption: caption),
              ),
            ),
        ],
      ),
    );
  }
}

final class _MediaCountTile extends StatelessWidget {
  final String value;
  final String caption;

  const _MediaCountTile({required this.value, required this.caption});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              child: Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Text(
              caption,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, height: 1.15),
            ),
          ],
        ),
      ),
    );
  }
}
