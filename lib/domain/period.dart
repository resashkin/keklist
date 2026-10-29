import 'package:material_ui/material_ui.dart' hide DateUtils;
import 'package:keklist/presentation/core/helpers/date_utils.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';

enum PeriodType {
  today,
  yesterday,
  thisWeek,
  lastTwoWeeks,
  thisMonth,
  thisYear,
}

extension PeriodTypeExtension on PeriodType {
  String localizedTitle(BuildContext context) {
    switch (this) {
      case PeriodType.today:
        return context.l10n.today;
      case PeriodType.yesterday:
        return context.l10n.yesterday;
      case PeriodType.thisWeek:
        return context.l10n.thisWeek;
      case PeriodType.lastTwoWeeks:
        return context.l10n.lastTwoWeeks;
      case PeriodType.thisMonth:
        return context.l10n.thisMonth;
      case PeriodType.thisYear:
        return context.l10n.thisYear;
    }
  }

  /// The first and last day of the period; it always ends today or yesterday.
  (int, int) dayRange() {
    final DateTime now = DateTime.now();
    final int today = DateUtils.getDayIndex(from: now);
    return switch (this) {
      PeriodType.today => (today, today),
      PeriodType.yesterday => (today - 1, today - 1),
      PeriodType.thisWeek => (DateUtils.getDayIndex(from: DateUtils.getWeekStart(now)), today),
      PeriodType.lastTwoWeeks => (today - 13, today),
      PeriodType.thisMonth => (DateUtils.getDayIndex(from: DateUtils.getMonthStart(now)), today),
      PeriodType.thisYear => (DateUtils.getDayIndex(from: DateUtils.getYearStart(now)), today),
    };
  }
}
