import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/insights/insights_period.dart';
import 'package:keklist/domain/services/insights/insights_report.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';

/// Builds an [InsightsReport]. Pure: everything time-dependent comes from [InsightsPeriod].
/// See `documentation/INSIGHTS_REDESIGN_IMPLEMENTATION.md`.
final class InsightsCalculator {
  static const int maxEmotionPairs = 5;
  static const int maxRoundVideos = 12;

  final InsightsPeriod period;
  final List<Mind> _roots;
  final List<Mind> _allMinds;
  final Map<String, Emotion> _emotionById;

  /// Library photos/videos per day, from the gallery index.
  final Map<int, ({int photos, int videos})> libraryMediaByDay;

  InsightsCalculator({
    required this.period,
    required Iterable<Mind> minds,
    required Iterable<Emotion> emotions,
    this.libraryMediaByDay = const {},
  }) : _allMinds = minds.toList(),
       _roots = minds.where((mind) => mind.rootId == null).toList(),
       _emotionById = {for (final Emotion emotion in emotions) emotion.id: emotion};

  InsightsReport build() {
    final List<Mind> currentRoots = _rootsIn(period.current);
    return InsightsReport(
      period: period,
      counters: _counters(currentRoots),
      brightest: _brightest(),
      emotionShares: _emotionShares(currentRoots),
      emotionTrend: _emotionTrend(),
      emotionPairs: _emotionPairs(currentRoots),
      emotionRhythm: _emotionRhythm(currentRoots),
      streak: _streak(),
      heatmap: _heatmap(),
      mindsByHour: _mindsByHour(currentRoots),
      onThisDay: _onThisDay(),
      media: _media(),
    );
  }

  List<Mind> _rootsIn(DayRange range) => _roots.where((mind) => range.contains(mind.dayIndex)).toList();

  InsightsCounters _counters(List<Mind> currentRoots) {
    final DayRange? previousRange = period.previous;
    final List<Mind>? previousRoots = previousRange == null ? null : _rootsIn(previousRange);
    int words(DayRange range) => _allMinds
        .where((mind) => range.contains(mind.dayIndex))
        .fold(0, (sum, mind) => sum + _wordCount(mind.plainNote));
    int activeDays(List<Mind> minds) => minds.map((mind) => mind.dayIndex).toSet().length;
    return InsightsCounters(
      minds: InsightsComparison(currentRoots.length, previousRoots?.length),
      activeDays: InsightsComparison(activeDays(currentRoots), previousRoots == null ? null : activeDays(previousRoots)),
      words: InsightsComparison(words(period.current), previousRange == null ? null : words(previousRange)),
    );
  }

  static int _wordCount(String text) => text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;

  /// Score = minds + 2 × distinct emotions + media (minds with audio/video and library items).
  BrightestSegment? _brightest() {
    BrightestSegment? best;
    for (final DayRange range in period.segments) {
      final List<Mind> minds = _rootsIn(range);
      final int emotionCount = minds.expand((mind) => mind.emotionIds).where(_emotionById.containsKey).toSet().length;
      final int mediaMinds = minds.where((mind) => mind.noteContent.hasMedia).length;
      final int libraryMedia = range.days.fold(0, (sum, day) {
        final ({int photos, int videos})? media = libraryMediaByDay[day];
        return sum + (media == null ? 0 : media.photos + media.videos);
      });
      final int mediaCount = mediaMinds + libraryMedia;
      final int score = minds.length + 2 * emotionCount + mediaCount;
      if (score == 0 || (best != null && score <= best.score)) continue;
      best = BrightestSegment(
        range: range,
        score: score,
        mindCount: minds.length,
        emotionCount: emotionCount,
        mediaCount: mediaCount,
        mindIds: minds.map((mind) => mind.id).toList(),
      );
    }
    return best;
  }

  List<Emotion> _lineage(Emotion emotion) {
    final List<Emotion> chain = [emotion];
    final Set<String> seen = {emotion.id};
    Emotion? current = emotion.parentId == null ? null : _emotionById[emotion.parentId];
    while (current != null && seen.add(current.id)) {
      chain.insert(0, current);
      current = current.parentId == null ? null : _emotionById[current.parentId];
    }
    return chain;
  }

  Set<String> _topLevelIdsOf(Mind mind) =>
      mind.emotionIds.map((id) => _emotionById[id]).whereType<Emotion>().map((e) => _lineage(e).first.id).toSet();

  /// Each mind counts once per top-level emotion it touches, and once per child below it.
  List<EmotionShare> _emotionShares(List<Mind> minds) {
    final Map<String, List<String>> rootMinds = {};
    final Map<String, Map<String, List<String>>> childMinds = {};
    for (final Mind mind in minds) {
      final Map<String, Set<String>> childrenByRoot = {};
      for (final Emotion emotion in mind.emotionIds.map((id) => _emotionById[id]).whereType<Emotion>()) {
        final List<Emotion> lineage = _lineage(emotion);
        final Set<String> children = childrenByRoot.putIfAbsent(lineage.first.id, () => {});
        if (lineage.length > 1) children.add(lineage[1].id);
      }
      childrenByRoot.forEach((rootId, children) {
        rootMinds.putIfAbsent(rootId, () => []).add(mind.id);
        for (final String childId in children) {
          childMinds.putIfAbsent(rootId, () => {}).putIfAbsent(childId, () => []).add(mind.id);
        }
      });
    }
    final List<EmotionShare> shares = [
      for (final MapEntry<String, List<String>> entry in rootMinds.entries)
        EmotionShare(
          emotionId: entry.key,
          mindIds: entry.value,
          children: [
            for (final MapEntry<String, List<String>> child in (childMinds[entry.key] ?? const {}).entries)
              EmotionShare(emotionId: child.key, mindIds: child.value),
          ]..sort((a, b) => b.count.compareTo(a.count)),
        ),
    ];
    return shares..sort((a, b) => b.count.compareTo(a.count));
  }

  List<EmotionTrendBucket> _emotionTrend() => [
    for (final DayRange range in period.segments)
      EmotionTrendBucket(range: range, counts: _countByTopLevel(_rootsIn(range))),
  ];

  Map<String, int> _countByTopLevel(Iterable<Mind> minds) {
    final Map<String, int> counts = {};
    for (final Mind mind in minds) {
      for (final String id in _topLevelIdsOf(mind)) {
        counts[id] = (counts[id] ?? 0) + 1;
      }
    }
    return counts;
  }

  List<EmotionPair> _emotionPairs(List<Mind> minds) {
    final Map<(String, String), List<String>> pairs = {};
    for (final Mind mind in minds) {
      final List<String> ids = mind.emotionIds.where(_emotionById.containsKey).toSet().toList()..sort();
      for (int i = 0; i < ids.length; i++) {
        for (int j = i + 1; j < ids.length; j++) {
          pairs.putIfAbsent((ids[i], ids[j]), () => []).add(mind.id);
        }
      }
    }
    final List<EmotionPair> result = [
      for (final MapEntry<(String, String), List<String>> entry in pairs.entries)
        EmotionPair(firstId: entry.key.$1, secondId: entry.key.$2, mindIds: entry.value),
    ]..sort((a, b) => b.count.compareTo(a.count));
    return result.take(maxEmotionPairs).toList();
  }

  static DayPart dayPartOf(int hour) => switch (hour) {
    < 6 => DayPart.night,
    < 12 => DayPart.morning,
    < 18 => DayPart.afternoon,
    _ => DayPart.evening,
  };

  EmotionRhythm _emotionRhythm(List<Mind> minds) {
    final Map<int, Map<String, int>> byWeekday = {};
    final Map<DayPart, Map<String, int>> byDayPart = {};
    final Map<int, List<String>> weekdayMindIds = {};
    final Map<DayPart, List<String>> dayPartMindIds = {};
    for (final Mind mind in minds) {
      final Set<String> ids = _topLevelIdsOf(mind);
      if (ids.isEmpty) continue;
      final int weekdayIndex = InsightsPeriod.calendarDateOf(mind.dayIndex).weekday;
      final DayPart dayPart = dayPartOf(mind.creationDate.toLocal().hour);
      weekdayMindIds.putIfAbsent(weekdayIndex, () => []).add(mind.id);
      dayPartMindIds.putIfAbsent(dayPart, () => []).add(mind.id);
      final Map<String, int> weekday = byWeekday.putIfAbsent(weekdayIndex, () => {});
      final Map<String, int> part = byDayPart.putIfAbsent(dayPart, () => {});
      for (final String id in ids) {
        weekday[id] = (weekday[id] ?? 0) + 1;
        part[id] = (part[id] ?? 0) + 1;
      }
    }
    return EmotionRhythm(
      byWeekday: byWeekday,
      byDayPart: byDayPart,
      weekdayMindIds: weekdayMindIds,
      dayPartMindIds: dayPartMindIds,
    );
  }

  StreakInsight _streak() {
    final Set<int> days = _roots.map((mind) => mind.dayIndex).toSet();
    final bool isTodayDone = days.contains(period.today);
    int current = 0;
    for (int day = isTodayDone ? period.today : period.today - 1; days.contains(day); day--) {
      current++;
    }
    int longest = 0;
    for (final int day in days) {
      if (days.contains(day - 1)) continue;
      int length = 0;
      while (days.contains(day + length)) {
        length++;
      }
      if (length > longest) longest = length;
    }
    return StreakInsight(current: current, longest: longest, isTodayDone: isTodayDone);
  }

  Map<int, int> _heatmap() {
    final DayRange range = period.heatmapRange;
    final Map<int, int> counts = {};
    for (final Mind mind in _roots.where((mind) => range.contains(mind.dayIndex))) {
      counts[mind.dayIndex] = (counts[mind.dayIndex] ?? 0) + 1;
    }
    return counts;
  }

  List<int> _mindsByHour(List<Mind> minds) {
    final List<int> hours = List.filled(24, 0);
    for (final Mind mind in minds) {
      hours[mind.creationDate.toLocal().hour]++;
    }
    return hours;
  }

  /// A week, a month, half a year, a year and two years back; a day missing in a shorter month falls on its last day.
  List<OnThisDayGroup> _onThisDay() {
    final DateTime today = InsightsPeriod.calendarDateOf(period.today);
    final Map<int, List<String>> mindsByDay = {};
    for (final Mind mind in _roots) {
      mindsByDay.putIfAbsent(mind.dayIndex, () => []).add(mind.id);
    }
    int monthsBack(int months) {
      final int lastDay = DateTime.utc(today.year, today.month - months + 1, 0).day;
      return DateUtils.getDayIndex(
        from: DateTime.utc(today.year, today.month - months, today.day > lastDay ? lastDay : today.day),
      );
    }

    return [
      for (final MemoryPoint point in MemoryPoint.values)
        if (switch (point) {
              MemoryPoint.weekAgo => period.today - 7,
              MemoryPoint.monthAgo => monthsBack(1),
              MemoryPoint.halfYearAgo => monthsBack(6),
              MemoryPoint.yearAgo => monthsBack(12),
              MemoryPoint.twoYearsAgo => monthsBack(24),
            }
            case final int day)
          if (mindsByDay[day] case final ids?) OnThisDayGroup(point: point, dayIndex: day, mindIds: ids),
    ];
  }

  MediaInsight _media() {
    final List<Mind> minds = _allMinds.where((mind) => period.current.contains(mind.dayIndex)).toList();
    int photos = 0;
    int videos = 0;
    for (final int day in period.current.days) {
      final ({int photos, int videos})? media = libraryMediaByDay[day];
      if (media == null) continue;
      photos += media.photos;
      videos += media.videos;
    }
    final List<Mind> voiceMinds = minds.where((mind) => mind.noteContent.hasVideo || mind.noteContent.hasAudio).toList()
      ..sort((a, b) => b.creationDate.compareTo(a.creationDate));
    return MediaInsight(
      libraryPhotos: photos,
      libraryVideos: videos,
      audioMinds: minds.where((mind) => mind.noteContent.hasAudio).length,
      videoMinds: minds.where((mind) => mind.noteContent.hasVideo).length,
      voiceMindIds: voiceMinds.take(maxRoundVideos).map((mind) => mind.id).toList(),
    );
  }
}
