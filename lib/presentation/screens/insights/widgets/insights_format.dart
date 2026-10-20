import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/services/insights/insights_period.dart';
import 'package:keklist/domain/services/insights/insights_report.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';

abstract final class InsightsFormat {
  static String _locale(BuildContext context) => Localizations.localeOf(context).toString();

  static DateTime dateOf(int dayIndex) => InsightsPeriod.calendarDateOf(dayIndex);

  static String day(BuildContext context, int dayIndex) => DateFormat.yMMMd(_locale(context)).format(dateOf(dayIndex));

  static String number(BuildContext context, int value) => NumberFormat.decimalPattern(_locale(context)).format(value);

  static String signed(BuildContext context, int value) => value > 0 ? '+${number(context, value)}' : number(context, value);

  /// "Tue, Oct 20" / "Oct 5 – 11" / "October" / "2025", by the period's segment size.
  static String segment(BuildContext context, InsightsPeriodKind kind, DayRange range) {
    final String locale = _locale(context);
    final DateTime start = dateOf(range.start);
    return switch (kind) {
      InsightsPeriodKind.week => DateFormat.MMMEd(locale).format(start),
      InsightsPeriodKind.month =>
        '${DateFormat.MMMd(locale).format(start)} – ${DateFormat.MMMd(locale).format(dateOf(range.end - 1))}',
      InsightsPeriodKind.year => DateFormat.LLLL(locale).format(start),
      InsightsPeriodKind.allTime => DateFormat.y(locale).format(start),
    };
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
