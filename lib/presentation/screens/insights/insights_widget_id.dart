import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';

enum InsightsCategory {
  summary(Icons.auto_awesome, Colors.indigoAccent),
  emotions(Icons.favorite, Colors.pinkAccent),
  activity(Icons.local_fire_department, Colors.orangeAccent),
  memories(Icons.history, Colors.purpleAccent),
  media(Icons.photo_library, Colors.tealAccent);

  final IconData icon;
  final Color color;

  const InsightsCategory(this.icon, this.color);

  String title(BuildContext context) => switch (this) {
    InsightsCategory.summary => context.l10n.insightsCategorySummary,
    InsightsCategory.emotions => context.l10n.insightsCategoryEmotions,
    InsightsCategory.activity => context.l10n.insightsCategoryActivity,
    InsightsCategory.memories => context.l10n.insightsCategoryMemories,
    InsightsCategory.media => context.l10n.insightsCategoryMedia,
  };
}

/// Analytics cards in their default order; the saved order stores [name]s.
enum InsightsWidgetId {
  counters(InsightsCategory.summary),
  brightest(InsightsCategory.summary),
  emotionDistribution(InsightsCategory.emotions),
  emotionTrend(InsightsCategory.emotions),
  emotionPairs(InsightsCategory.emotions),
  emotionRhythm(InsightsCategory.emotions),
  streak(InsightsCategory.activity),
  heatmap(InsightsCategory.activity),
  activityTime(InsightsCategory.activity),
  onThisDay(InsightsCategory.memories),
  mediaCounters(InsightsCategory.media),
  roundVideos(InsightsCategory.media);

  final InsightsCategory category;

  const InsightsWidgetId(this.category);

  String title(BuildContext context) => switch (this) {
    InsightsWidgetId.counters => context.l10n.insightsCounters,
    InsightsWidgetId.brightest => context.l10n.insightsBrightestPeriod,
    InsightsWidgetId.emotionDistribution => context.l10n.insightsEmotionDistribution,
    InsightsWidgetId.emotionTrend => context.l10n.insightsEmotionTrend,
    InsightsWidgetId.emotionPairs => context.l10n.insightsEmotionPairs,
    InsightsWidgetId.emotionRhythm => context.l10n.insightsEmotionRhythm,
    InsightsWidgetId.streak => context.l10n.insightsStreak,
    InsightsWidgetId.heatmap => context.l10n.insightsHeatmap,
    InsightsWidgetId.activityTime => context.l10n.insightsActivityTime,
    InsightsWidgetId.onThisDay => context.l10n.insightsOnThisDay,
    InsightsWidgetId.mediaCounters => context.l10n.insightsMediaCounters,
    InsightsWidgetId.roundVideos => context.l10n.insightsRoundVideos,
  };

  /// Saved ids first (unknown ones dropped), then any new cards in default order.
  static List<InsightsWidgetId> ordered(List<String> savedOrder) {
    final Map<String, InsightsWidgetId> byName = {for (final InsightsWidgetId id in values) id.name: id};
    final List<InsightsWidgetId> result = savedOrder.map((name) => byName[name]).whereType<InsightsWidgetId>().toSet().toList();
    return [...result, ...values.where((id) => !result.contains(id))];
  }
}
