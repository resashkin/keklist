import 'package:equatable/equatable.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';

enum InsightsPeriodKind { week, month, year, allTime }

/// Days `[start, end)` as day indexes.
final class DayRange with EquatableMixin {
  final int start;
  final int end;

  const DayRange(this.start, this.end);

  int get length => end - start;
  bool contains(int dayIndex) => dayIndex >= start && dayIndex < end;
  Iterable<int> get days sync* {
    for (int day = start; day < end; day++) {
      yield day;
    }
  }

  @override
  List<Object?> get props => [start, end];
}

/// The selected period up to today, the same elapsed span of the previous
/// period, and the segments one level below (week → days, month → weeks,
/// year → months, all time → years).
final class InsightsPeriod {
  final InsightsPeriodKind kind;
  final int today;

  /// `DateTime.monday` … `DateTime.sunday`, from the locale.
  final int firstDayOfWeek;
  final DayRange current;
  final DayRange? previous;

  const InsightsPeriod._({
    required this.kind,
    required this.today,
    required this.firstDayOfWeek,
    required this.current,
    required this.previous,
  });

  factory InsightsPeriod.of(
    InsightsPeriodKind kind, {
    required int today,
    required int firstDayOfWeek,
    int? firstMindDay,
  }) {
    final DateTime date = calendarDateOf(today);
    final int end = today + 1;
    switch (kind) {
      case InsightsPeriodKind.week:
        final int start = weekStart(today, firstDayOfWeek);
        return InsightsPeriod._(
          kind: kind,
          today: today,
          firstDayOfWeek: firstDayOfWeek,
          current: DayRange(start, end),
          previous: DayRange(start - 7, end - 7),
        );
      case InsightsPeriodKind.month:
        final int start = _dayOf(date.year, date.month, 1);
        final int previousStart = _dayOf(date.year, date.month - 1, 1);
        final int previousEnd = (previousStart + (end - start)).clamp(previousStart, start);
        return InsightsPeriod._(
          kind: kind,
          today: today,
          firstDayOfWeek: firstDayOfWeek,
          current: DayRange(start, end),
          previous: DayRange(previousStart, previousEnd),
        );
      case InsightsPeriodKind.year:
        final int start = _dayOf(date.year, 1, 1);
        final int previousStart = _dayOf(date.year - 1, 1, 1);
        final int previousEnd = (previousStart + (end - start)).clamp(previousStart, start);
        return InsightsPeriod._(
          kind: kind,
          today: today,
          firstDayOfWeek: firstDayOfWeek,
          current: DayRange(start, end),
          previous: DayRange(previousStart, previousEnd),
        );
      case InsightsPeriodKind.allTime:
        return InsightsPeriod._(
          kind: kind,
          today: today,
          firstDayOfWeek: firstDayOfWeek,
          current: DayRange(firstMindDay == null ? today : firstMindDay.clamp(0, today), end),
          previous: null,
        );
    }
  }

  static int weekStart(int dayIndex, int firstDayOfWeek) {
    final int weekday = calendarDateOf(dayIndex).weekday;
    return dayIndex - (weekday - firstDayOfWeek + 7) % 7;
  }

  /// Calendar fields of a day index, independent of the device time zone.
  static DateTime calendarDateOf(int dayIndex) =>
      DateTime.fromMillisecondsSinceEpoch(dayIndex * DateUtils.millisecondsInDay, isUtc: true);

  static int _dayOf(int year, int month, int day) => DateUtils.getDayIndex(from: DateTime.utc(year, month, day));

  /// Segments of [current], clipped to it.
  List<DayRange> get segments {
    final List<DayRange> result = [];
    int start = current.start;
    while (start < current.end) {
      final int next = switch (kind) {
        InsightsPeriodKind.week => start + 1,
        InsightsPeriodKind.month => weekStart(start, firstDayOfWeek) + 7,
        InsightsPeriodKind.year => _nextMonth(start),
        InsightsPeriodKind.allTime => _nextYear(start),
      };
      result.add(DayRange(start, next.clamp(start + 1, current.end)));
      start = next;
    }
    return result;
  }

  static int _nextMonth(int dayIndex) {
    final DateTime date = calendarDateOf(dayIndex);
    return _dayOf(date.year, date.month + 1, 1);
  }

  static int _nextYear(int dayIndex) => _dayOf(calendarDateOf(dayIndex).year + 1, 1, 1);

  /// Range the heatmap draws: the period itself, or the last 52 weeks for longer ones.
  DayRange get heatmapRange => switch (kind) {
    InsightsPeriodKind.week || InsightsPeriodKind.month => current,
    InsightsPeriodKind.year || InsightsPeriodKind.allTime => DayRange(
      weekStart(today - 52 * 7 + 7, firstDayOfWeek).clamp(kind == InsightsPeriodKind.year ? current.start : 0, today),
      today + 1,
    ),
  };
}
