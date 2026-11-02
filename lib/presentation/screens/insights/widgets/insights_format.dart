import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart' hide DateUtils;
import 'package:keklist/domain/services/insights/insights_period.dart';
import 'package:keklist/domain/services/insights/insights_report.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';

abstract final class InsightsFormat {
  static String _locale(BuildContext context) => Localizations.localeOf(context).toString();

  static DateTime dateOf(int dayIndex) => InsightsPeriod.calendarDateOf(dayIndex);

  static String day(BuildContext context, int dayIndex) => DateFormat.yMMMd(_locale(context)).format(dateOf(dayIndex));

  static String number(BuildContext context, int value) => NumberFormat.decimalPattern(_locale(context)).format(value);

  static String signed(BuildContext context, int value) => value > 0 ? '+${number(context, value)}' : number(context, value);

  /// "Tue, Oct 20, 2026" / "Week 42 · Oct 12 – Oct 18, 2026" / "October 2026" / "2025", by the segment size.
  static String segment(BuildContext context, InsightsPeriodKind kind, DayRange range, {required int firstDayOfWeek}) {
    final String locale = _locale(context);
    final DateTime start = dateOf(range.start);
    return switch (kind) {
      InsightsPeriodKind.week => DateFormat.yMMMEd(locale).format(start),
      InsightsPeriodKind.month =>
        '${context.l10n.insightsWeekNumber('${weekOfYear(range.start, firstDayOfWeek)}')} · '
            '${DateFormat.MMMd(locale).format(start)} – ${DateFormat.yMMMd(locale).format(dateOf(range.end - 1))}',
      InsightsPeriodKind.year => DateFormat('LLLL y', locale).format(start),
      InsightsPeriodKind.allTime => DateFormat.y(locale).format(start),
    };
  }

  /// ISO 8601 weeks when weeks start on Monday; otherwise week 1 is the one with January 1.
  static int weekOfYear(int dayIndex, int firstDayOfWeek) {
    final int weekStart = InsightsPeriod.weekStart(dayIndex, firstDayOfWeek);
    if (firstDayOfWeek == DateTime.monday) {
      final DateTime thursday = dateOf(weekStart + 3);
      final int january1 = DateUtils.getDayIndex(from: DateTime.utc(thursday.year, 1, 1));
      return (weekStart + 3 - january1) ~/ 7 + 1;
    }
    final int year = dateOf(weekStart + 6).year;
    final int firstWeek = InsightsPeriod.weekStart(
      DateUtils.getDayIndex(from: DateTime.utc(year, 1, 1)),
      firstDayOfWeek,
    );
    return (weekStart - firstWeek) ~/ 7 + 1;
  }

  /// Short axis label under a trend column.
  static String axis(BuildContext context, InsightsPeriodKind kind, DayRange range) {
    final String locale = _locale(context);
    final DateTime start = dateOf(range.start);
    return switch (kind) {
      InsightsPeriodKind.week => DateFormat.E(locale).format(start).characters.take(2).toString(),
      InsightsPeriodKind.month => DateFormat.d(locale).format(start),
      InsightsPeriodKind.year => DateFormat.LLL(locale).format(start).characters.take(1).toString().toUpperCase(),
      InsightsPeriodKind.allTime => DateFormat('yy', locale).format(start),
    };
  }

  static String periodTitle(BuildContext context, InsightsPeriodKind kind) => switch (kind) {
    InsightsPeriodKind.week => context.l10n.insightsPeriodWeek,
    InsightsPeriodKind.month => context.l10n.insightsPeriodMonth,
    InsightsPeriodKind.year => context.l10n.insightsPeriodYear,
    InsightsPeriodKind.allTime => context.l10n.insightsPeriodAllTime,
  };

  static String? comparison(BuildContext context, InsightsPeriodKind kind, InsightsComparison value) {
    final int? delta = value.delta;
    if (delta == null) return null;
    final String text = signed(context, delta);
    return switch (kind) {
      InsightsPeriodKind.week => context.l10n.insightsVsLastWeek(text),
      InsightsPeriodKind.month => context.l10n.insightsVsLastMonth(text),
      InsightsPeriodKind.year => context.l10n.insightsVsLastYear(text),
      InsightsPeriodKind.allTime => null,
    };
  }

  static String weekdayShort(BuildContext context, int weekday) =>
      DateFormat.E(_locale(context)).format(DateTime.utc(2024, 1, weekday)).characters.take(2).toString();

  static String dayPart(BuildContext context, DayPart part) => switch (part) {
    DayPart.night => context.l10n.insightsNight,
    DayPart.morning => context.l10n.insightsMorning,
    DayPart.afternoon => context.l10n.insightsAfternoon,
    DayPart.evening => context.l10n.insightsEvening,
  };
}
