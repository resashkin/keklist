import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/insights/insights_period.dart';
import 'package:keklist/domain/services/insights/insights_report.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/insights/insights_widget_id.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_card.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_format.dart';

/// Top-level emotions as bars; a chevron drills one level down.
final class InsightsEmotionDistributionCard extends StatefulWidget {
  final InsightsCardContext data;

  const InsightsEmotionDistributionCard({super.key, required this.data});

  @override
  State<InsightsEmotionDistributionCard> createState() => _InsightsEmotionDistributionCardState();
}

final class _InsightsEmotionDistributionCardState extends State<InsightsEmotionDistributionCard> {
  final Set<String> _expandedIds = {};

  @override
  Widget build(BuildContext context) {
    final List<EmotionShare> shares = widget.data.report.emotionShares;
    return InsightsCard(
      category: InsightsCategory.emotions,
      title: context.l10n.insightsEmotionDistribution,
      trailing: InsightsFormat.periodTitle(context, widget.data.report.period.kind),
      child: shares.isEmpty
          ? InsightsEmptyHint(context.l10n.insightsEmptyEmotions)
          : Column(
              children: [
                for (final EmotionShare share in shares) ...[
                  _row(context, share, max: shares.first.count, color: widget.data.colorOf(share.emotionId)),
                  if (_expandedIds.contains(share.emotionId))
                    for (final EmotionShare child in share.children)
                      _row(context, child, max: share.count, color: widget.data.colorOf(share.emotionId), indent: 28.0),
                ],
              ],
            ),
    );
  }

  Widget _row(BuildContext context, EmotionShare share, {required int max, required Color color, double indent = 0.0}) {
    final String title = widget.data.emotionById[share.emotionId]?.title ?? '';
    final bool isExpanded = _expandedIds.contains(share.emotionId);
    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: () => widget.data.openMinds(share.mindIds),
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: indent, top: 6.0, bottom: 6.0),
        child: Row(
          spacing: 8.0,
          children: [
            Text(widget.data.emojiOf(share.emotionId), style: const TextStyle(fontSize: 20.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.0,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  InsightsBar(fraction: share.count / max, color: color),
                ],
              ),
            ),
            SizedBox(
              width: 32.0,
              child: Text(InsightsFormat.number(context, share.count), textAlign: TextAlign.end),
            ),
            SizedBox(
              width: 32.0,
              child: share.children.isEmpty
                  ? null
                  : IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                      onPressed: () => setState(
                        () => isExpanded ? _expandedIds.remove(share.emotionId) : _expandedIds.add(share.emotionId),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stacked columns per segment, one color per top-level emotion.
final class InsightsEmotionTrendCard extends StatelessWidget {
  static const double _chartHeight = 120.0;

  final InsightsCardContext data;

  const InsightsEmotionTrendCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<EmotionTrendBucket> buckets = data.report.emotionTrend;
    final InsightsPeriodKind kind = data.report.period.kind;
    final int maxTotal = buckets.fold(0, (max, bucket) {
      final int total = bucket.counts.values.fold(0, (sum, value) => sum + value);
      return total > max ? total : max;
    });
    final List<String> legendIds = data.report.emotionShares.map((share) => share.emotionId).toList();
    return InsightsCard(
      category: InsightsCategory.emotions,
      title: context.l10n.insightsEmotionTrend,
      trailing: InsightsFormat.periodTitle(context, kind),
      child: maxTotal == 0
          ? InsightsEmptyHint(context.l10n.insightsEmptyEmotions)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8.0,
              children: [
                SizedBox(
                  height: _chartHeight + 18.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 4.0,
                    children: [
                      for (final EmotionTrendBucket bucket in buckets)
                        Expanded(child: _column(context, bucket, kind: kind, maxTotal: maxTotal, order: legendIds)),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 4.0,
                  children: [
                    for (final String id in legendIds)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4.0,
                        children: [
                          Container(
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(color: data.colorOf(id), shape: BoxShape.circle),
                          ),
                          Text(data.emojiOf(id)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _column(
    BuildContext context,
    EmotionTrendBucket bucket, {
    required InsightsPeriodKind kind,
    required int maxTotal,
    required List<String> order,
  }) {
    final List<String> mindIds = data.mindById.values
        .where((Mind mind) => mind.rootId == null && bucket.range.contains(mind.dayIndex) && mind.emotionIds.isNotEmpty)
        .map((mind) => mind.id)
        .toList();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: mindIds.isEmpty ? null : () => data.openMinds(mindIds),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Column(
              children: [
                for (final String id in order.reversed)
                  if ((bucket.counts[id] ?? 0) > 0)
                    Container(height: _chartHeight * bucket.counts[id]! / maxTotal, color: data.colorOf(id)),
              ],
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            InsightsFormat.axis(context, kind, bucket.range),
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}

final class InsightsEmotionPairsCard extends StatelessWidget {
  final InsightsCardContext data;

  const InsightsEmotionPairsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<EmotionPair> pairs = data.report.emotionPairs;
    return InsightsCard(
      category: InsightsCategory.emotions,
      title: context.l10n.insightsEmotionPairs,
      trailing: InsightsFormat.periodTitle(context, data.report.period.kind),
      child: pairs.isEmpty
          ? InsightsEmptyHint(context.l10n.insightsEmptyPairs)
          : Column(
              children: [
                for (final EmotionPair pair in pairs)
                  InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () => data.openMinds(pair.mindIds),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        spacing: 8.0,
                        children: [
                          Text(
                            '${data.emojiOf(pair.firstId)} ${data.emojiOf(pair.secondId)}',
                            style: const TextStyle(fontSize: 20.0),
                          ),
                          Expanded(
                            child: Text(
                              '${data.emotionById[pair.firstId]?.title} + ${data.emotionById[pair.secondId]?.title}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text('×${InsightsFormat.number(context, pair.count)}'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Dominant top-level emotion per weekday and per part of the day.
final class InsightsEmotionRhythmCard extends StatelessWidget {
  final InsightsCardContext data;

  const InsightsEmotionRhythmCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final EmotionRhythm rhythm = data.report.emotionRhythm;
    final int firstDay = data.report.period.firstDayOfWeek;
    final List<int> weekdays = [for (int i = 0; i < 7; i++) (firstDay - 1 + i) % 7 + 1];
    final TextStyle? labelStyle = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: Theme.of(context).hintColor);
    return InsightsCard(
      category: InsightsCategory.emotions,
      title: context.l10n.insightsEmotionRhythm,
      trailing: InsightsFormat.periodTitle(context, data.report.period.kind),
      child: rhythm.isEmpty
          ? InsightsEmptyHint(context.l10n.insightsEmptyEmotions)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8.0,
              children: [
                Text(context.l10n.insightsByWeekday, style: labelStyle),
                Row(
                  children: [
                    for (final int weekday in weekdays)
                      Expanded(
                        child: _cell(
                          label: InsightsFormat.weekdayShort(context, weekday),
                          emotionId: EmotionRhythm.dominant(rhythm.byWeekday[weekday]),
                          mindIds: rhythm.weekdayMindIds[weekday] ?? const [],
                          labelStyle: labelStyle,
                        ),
                      ),
                  ],
                ),
                Text(context.l10n.insightsByDayPart, style: labelStyle),
                Row(
                  children: [
                    for (final DayPart part in DayPart.values)
                      Expanded(
                        child: _cell(
                          label: InsightsFormat.dayPart(context, part),
                          emotionId: EmotionRhythm.dominant(rhythm.byDayPart[part]),
                          mindIds: rhythm.dayPartMindIds[part] ?? const [],
                          labelStyle: labelStyle,
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _cell({
    required String label,
    required String? emotionId,
    required List<String> mindIds,
    required TextStyle? labelStyle,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: mindIds.isEmpty ? null : () => data.openMinds(mindIds),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          children: [
            Text(emotionId == null ? '·' : data.emojiOf(emotionId), style: const TextStyle(fontSize: 22.0)),
            Text(label, style: labelStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
