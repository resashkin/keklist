import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/insights/insights_calculator.dart';
import 'package:keklist/domain/services/insights/insights_period.dart';
import 'package:keklist/domain/services/insights/insights_report.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';

int _day(int year, int month, int day) => DateUtils.getDayIndex(from: DateTime.utc(year, month, day));

// Tuesday.
final int _today = _day(2026, 10, 20);

Emotion _emotion(String id, {String? parentId}) => Emotion(
  id: id,
  title: id,
  emoji: id,
  parentId: parentId,
  isArchived: false,
  orderIndex: 0,
  creationDate: DateTime.utc(2026),
);

int _mindCounter = 0;

Mind _mind(int dayIndex, {List<String> emotionIds = const [], String note = 'a b', int hour = 10, String? rootId}) {
  final DateTime date = InsightsPeriod.calendarDateOf(dayIndex);
  return Mind(
    id: 'm${_mindCounter++}',
    note: note,
    dayIndex: dayIndex,
    sortIndex: 0,
    creationDate: DateTime(date.year, date.month, date.day, hour),
    rootId: rootId,
    emotionIds: emotionIds,
  );
}

InsightsReport _report(
  InsightsPeriodKind kind,
  List<Mind> minds, {
  List<Emotion> emotions = const [],
  int firstDayOfWeek = DateTime.monday,
  Map<int, ({int photos, int videos})> library = const {},
}) {
  final int? firstDay = minds.isEmpty ? null : minds.map((m) => m.dayIndex).reduce((a, b) => a < b ? a : b);
  return InsightsCalculator(
    period: InsightsPeriod.of(kind, today: _today, firstDayOfWeek: firstDayOfWeek, firstMindDay: firstDay),
    minds: minds,
    emotions: emotions,
    libraryMediaByDay: library,
  ).build();
}

void main() {
  group('InsightsPeriod', () {
    test('week starts on the locale first day and compares with the same days last week', () {
      final InsightsPeriod monday = InsightsPeriod.of(InsightsPeriodKind.week, today: _today, firstDayOfWeek: DateTime.monday);
      expect(monday.current, DayRange(_day(2026, 10, 19), _today + 1));
      expect(monday.previous, DayRange(_day(2026, 10, 12), _day(2026, 10, 14)));
      expect(monday.segments.length, 2);

      final InsightsPeriod sunday = InsightsPeriod.of(InsightsPeriodKind.week, today: _today, firstDayOfWeek: DateTime.sunday);
      expect(sunday.current.start, _day(2026, 10, 18));
    });

    test('month compares with the same elapsed days of the previous month', () {
      final InsightsPeriod period = InsightsPeriod.of(InsightsPeriodKind.month, today: _today, firstDayOfWeek: DateTime.monday);
      expect(period.current, DayRange(_day(2026, 10, 1), _today + 1));
      expect(period.previous, DayRange(_day(2026, 9, 1), _day(2026, 9, 21)));
      expect(period.segments.first, DayRange(_day(2026, 10, 1), _day(2026, 10, 5)));
      expect(period.segments.last.end, _today + 1);
    });

    test('year segments are months and all time has no previous period', () {
      final InsightsPeriod year = InsightsPeriod.of(InsightsPeriodKind.year, today: _today, firstDayOfWeek: DateTime.monday);
      expect(year.segments.length, 10);
      expect(year.segments[1], DayRange(_day(2026, 2, 1), _day(2026, 3, 1)));

      final InsightsPeriod all = InsightsPeriod.of(
        InsightsPeriodKind.allTime,
        today: _today,
        firstDayOfWeek: DateTime.monday,
        firstMindDay: _day(2024, 6, 1),
      );
      expect(all.previous, isNull);
      expect(all.segments.length, 3);
    });
  });

  test('counters count root minds, active days and words against the previous period', () {
    final InsightsReport report = _report(InsightsPeriodKind.week, [
      _mind(_today, note: 'one two three'),
      _mind(_today, note: 'four'),
      _mind(_today - 1, note: 'five'),
      _mind(_today, note: 'reply words', rootId: 'x'),
      _mind(_day(2026, 10, 12), note: 'old'),
    ]);
    expect(report.counters.minds.value, 3);
    expect(report.counters.minds.previous, 1);
    expect(report.counters.activeDays.value, 2);
    expect(report.counters.words.value, 7);
    expect(report.counters.words.delta, 6);
  });

  test('brightest segment mixes minds, emotions and media', () {
    final List<Emotion> emotions = [_emotion('joy'), _emotion('sad')];
    final InsightsReport report = _report(
      InsightsPeriodKind.week,
      [
        _mind(_today - 1),
        _mind(_today - 1),
        _mind(_today, emotionIds: ['joy', 'sad']),
      ],
      emotions: emotions,
      library: {_today - 1: (photos: 1, videos: 0)},
    );
    expect(report.brightest!.range, DayRange(_today, _today + 1));
    expect(report.brightest!.score, 5);
  });

  test('emotion shares roll up to top level, count fully in each and drill one level down', () {
    final List<Emotion> emotions = [
      _emotion('joy'),
      _emotion('calm', parentId: 'joy'),
      _emotion('serene', parentId: 'calm'),
      _emotion('sad'),
    ];
    final InsightsReport report = _report(
      InsightsPeriodKind.week,
      [
        _mind(_today, emotionIds: ['serene', 'sad']),
        _mind(_today, emotionIds: ['joy']),
        _mind(_today, emotionIds: ['calm', 'serene']),
      ],
      emotions: emotions,
    );
    final EmotionShare joy = report.emotionShares.first;
    expect(joy.emotionId, 'joy');
    expect(joy.count, 3);
    expect(joy.children.single.emotionId, 'calm');
    expect(joy.children.single.count, 2);
    expect(report.emotionShares.last.emotionId, 'sad');
    expect(report.emotionPairs.first.count, 1);
  });

  test('rhythm groups emotions by weekday and part of day', () {
    final InsightsReport report = _report(
      InsightsPeriodKind.week,
      [_mind(_today, emotionIds: ['joy'], hour: 21)],
      emotions: [_emotion('joy')],
    );
    expect(report.emotionRhythm.byWeekday[DateTime.tuesday], {'joy': 1});
    expect(EmotionRhythm.dominant(report.emotionRhythm.byDayPart[DayPart.evening]), 'joy');
  });

  test('streak survives until today ends and longest is tracked', () {
    final InsightsReport waiting = _report(InsightsPeriodKind.week, [
      _mind(_today - 1),
      _mind(_today - 2),
      _mind(_today - 10),
      _mind(_today - 11),
      _mind(_today - 12),
    ]);
    expect(waiting.streak.current, 2);
    expect(waiting.streak.isTodayDone, false);
    expect(waiting.streak.longest, 3);

    final InsightsReport broken = _report(InsightsPeriodKind.week, [_mind(_today - 2)]);
    expect(broken.streak.current, 0);
  });

  test('memories look a week, a month, half a year, one and two years back', () {
    final DateTime today = InsightsPeriod.calendarDateOf(_today);
    int back(int months) => _day(today.year, today.month - months, today.day);
    final Mind week = _mind(_today - 7);
    final Mind month = _mind(back(1));
    final Mind halfYear = _mind(back(6));
    final Mind year = _mind(back(12));
    final Mind twoYears = _mind(back(24));
    final InsightsReport report = _report(InsightsPeriodKind.week, [
      week,
      month,
      halfYear,
      year,
      twoYears,
      _mind(back(36)),
      _mind(_today - 8),
    ]);
    expect(report.onThisDay.map((group) => group.point), MemoryPoint.values);
    expect(report.onThisDay.map((group) => group.mindIds.single), [
      week.id,
      month.id,
      halfYear.id,
      year.id,
      twoYears.id,
    ]);
  });

  test('media sums library items of the period and lists round videos', () {
    final InsightsReport report = _report(
      InsightsPeriodKind.week,
      [_mind(_today, note: '[audio:a.m4a]')],
      library: {_today: (photos: 3, videos: 1), _day(2026, 1, 1): (photos: 9, videos: 9)},
    );
    expect(report.media.libraryPhotos, 3);
    expect(report.media.libraryVideos, 1);
  });

  test('hours histogram counts root minds by local hour', () {
    final InsightsReport report = _report(InsightsPeriodKind.week, [_mind(_today, hour: 7), _mind(_today, hour: 7)]);
    expect(report.mindsByHour[7], 2);
    expect(report.heatmap[_today], 2);
  });
}
