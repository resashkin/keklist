import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/insights/insights_period.dart';
import 'package:keklist/domain/services/insights/insights_report.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/insights/insights_widget_id.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_card.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_format.dart';

final class InsightsStreakCard extends StatelessWidget {
  final InsightsCardContext data;

  const InsightsStreakCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final StreakInsight streak = data.report.streak;
    final String? hint = switch (streak) {
      StreakInsight(current: 0) => context.l10n.insightsEmptyStreak,
      StreakInsight(isTodayDone: false) => context.l10n.insightsStreakKeepGoing,
      _ => null,
    };
    return InsightsCard(
      category: InsightsCategory.activity,
      title: context.l10n.insightsStreak,
      onTap: () => data.openDay(data.report.period.today),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4.0,
        children: [
          InsightsValue(
            value: InsightsFormat.number(context, streak.current),
            caption: context.l10n.insightsStreakLabel,
            footnote: context.l10n.insightsLongestStreak(InsightsFormat.number(context, streak.longest)),
          ),
          if (hint != null) InsightsEmptyHint(hint),
        ],
      ),
    );
  }
}

/// A compact calendar for a week or month, days ahead faded; a scrollable 52-week strip for longer periods.
final class InsightsHeatmapCard extends StatelessWidget {
  static const int _calendarMaxDays = 31;
  static const double _calendarCell = 28.0;
  static const double _calendarGap = 4.0;
  static const double _stripCell = 12.0;
  static const double _gap = 3.0;

  final InsightsCardContext data;

  const InsightsHeatmapCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final InsightsPeriod period = data.report.period;
    final DayRange range = period.heatmapRange;
    final Map<int, int> counts = data.report.heatmap;
    final int maxCount = counts.values.fold(0, (max, value) => value > max ? value : max);
    return InsightsCard(
      category: InsightsCategory.activity,
      title: context.l10n.insightsHeatmap,
      trailing: InsightsFormat.periodTitle(context, period.kind),
      child: maxCount == 0
          ? InsightsEmptyHint(context.l10n.insightsEmptyPeriod)
          : range.length <= _calendarMaxDays
          ? Center(child: _calendar(context, period, range, counts, maxCount))
          : _strip(context, period, range, counts, maxCount),
    );
  }

  Color _colorFor(BuildContext context, int count, int maxCount) => count == 0
      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)
      : InsightsCategory.activity.color.withValues(alpha: 0.25 + 0.75 * count / maxCount);

  Widget _calendar(BuildContext context, InsightsPeriod period, DayRange range, Map<int, int> counts, int maxCount) {
    final ThemeData theme = Theme.of(context);
    final int gridStart = InsightsPeriod.weekStart(range.start, period.firstDayOfWeek);
    final int weekCount = ((range.end - gridStart) / 7).ceil();
    Widget cell(Widget child) => SizedBox.square(dimension: _calendarCell, child: child);
    Widget day(int day) {
      if (!range.contains(day)) return cell(const SizedBox.shrink());
      final bool isAhead = day > period.today;
      final Widget box = Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isAhead
              ? theme.colorScheme.onSurface.withValues(alpha: 0.02)
              : _colorFor(context, counts[day] ?? 0, maxCount),
          borderRadius: BorderRadius.circular(6.0),
          border: day == period.today ? Border.all(color: InsightsCategory.activity.color) : null,
        ),
        child: Text(
          '${InsightsFormat.dateOf(day).day}',
          style: theme.textTheme.labelSmall?.copyWith(color: isAhead ? theme.disabledColor : null),
        ),
      );
      return cell(
        isAhead ? box : InkWell(borderRadius: BorderRadius.circular(6.0), onTap: () => data.openDay(day), child: box),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: _calendarGap,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: _calendarGap,
          children: [
            for (int offset = 0; offset < 7; offset++)
              cell(
                Center(
                  child: Text(
                    InsightsFormat.weekdayShort(context, (period.firstDayOfWeek - 1 + offset) % 7 + 1),
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                  ),
                ),
              ),
          ],
        ),
        for (int week = 0; week < weekCount; week++)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: _calendarGap,
            children: [for (int offset = 0; offset < 7; offset++) day(gridStart + week * 7 + offset)],
          ),
      ],
    );
  }

  Widget _strip(BuildContext context, InsightsPeriod period, DayRange range, Map<int, int> counts, int maxCount) {
    final int gridStart = InsightsPeriod.weekStart(range.start, period.firstDayOfWeek);
    final int weekCount = ((range.end - gridStart) / 7).ceil();
    return SizedBox(
      height: 7 * (_stripCell + _gap),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: weekCount,
        separatorBuilder: (_, _) => const SizedBox(width: _gap),
        itemBuilder: (context, index) {
          final int weekStart = gridStart + (weekCount - 1 - index) * 7;
          return Column(
            spacing: _gap,
            children: [
              for (int day = weekStart; day < weekStart + 7; day++)
                GestureDetector(
                  onTap: range.contains(day) ? () => data.openDay(day) : null,
                  child: Container(
                    width: _stripCell,
                    height: _stripCell,
                    decoration: BoxDecoration(
                      color: range.contains(day) ? _colorFor(context, counts[day] ?? 0, maxCount) : Colors.transparent,
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Minds per hour of the day in the period.
final class InsightsActivityTimeCard extends StatelessWidget {
  static const double _chartHeight = 80.0;

  final InsightsCardContext data;

  const InsightsActivityTimeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<int> hours = data.report.mindsByHour;
    final int maxCount = hours.fold(0, (max, value) => value > max ? value : max);
    final int peakHour = hours.indexOf(maxCount);
    final String locale = Localizations.localeOf(context).toString();
    String hourLabel(int hour) => DateFormat.Hm(locale).format(DateTime(2000, 1, 1, hour));
    final TextStyle? axisStyle = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: Theme.of(context).hintColor);
    return InsightsCard(
      category: InsightsCategory.activity,
      title: context.l10n.insightsActivityTime,
      trailing: InsightsFormat.periodTitle(context, data.report.period.kind),
      child: maxCount == 0
          ? InsightsEmptyHint(context.l10n.insightsEmptyPeriod)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6.0,
              children: [
                Text(context.l10n.insightsPeakHour(hourLabel(peakHour))),
                SizedBox(
                  height: _chartHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 2.0,
                    children: [
                      for (int hour = 0; hour < 24; hour++)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: hours[hour] == 0 ? null : () => data.openMinds(_mindIdsAt(hour)),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: hours[hour] == 0 ? 2.0 : _chartHeight * hours[hour] / maxCount,
                                decoration: BoxDecoration(
                                  color: InsightsCategory.activity.color.withValues(alpha: hour == peakHour ? 1.0 : 0.5),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [for (final int hour in const [0, 6, 12, 18, 23]) Text(hourLabel(hour), style: axisStyle)],
                ),
              ],
            ),
    );
  }

  List<String> _mindIdsAt(int hour) => data.mindById.values
      .where(
        (Mind mind) =>
            mind.rootId == null &&
            data.report.period.current.contains(mind.dayIndex) &&
            mind.creationDate.toLocal().hour == hour,
      )
      .map((mind) => mind.id)
      .toList();
}
