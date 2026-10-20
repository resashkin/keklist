import 'package:keklist/domain/services/insights/insights_period.dart';

/// A value of the selected period next to the same span of the previous one.
final class InsightsComparison {
  final int value;
  final int? previous;

  const InsightsComparison(this.value, this.previous);

  int? get delta => previous == null ? null : value - previous!;
}

final class InsightsCounters {
  final InsightsComparison minds;
  final InsightsComparison activeDays;
  final InsightsComparison words;

  const InsightsCounters({required this.minds, required this.activeDays, required this.words});
}

final class BrightestSegment {
  final DayRange range;
  final int score;
  final int mindCount;
  final int emotionCount;
  final int mediaCount;
  final List<String> mindIds;

  const BrightestSegment({
    required this.range,
    required this.score,
    required this.mindCount,
    required this.emotionCount,
    required this.mediaCount,
    required this.mindIds,
  });
}

/// Minds tagged with [emotionId] or anything under it; [children] drill one level down.
final class EmotionShare {
  final String emotionId;
  final List<String> mindIds;
  final List<EmotionShare> children;

  const EmotionShare({required this.emotionId, required this.mindIds, this.children = const []});

  int get count => mindIds.length;
}

final class EmotionTrendBucket {
  final DayRange range;

  /// Top-level emotion id → minds in the bucket.
  final Map<String, int> counts;

  const EmotionTrendBucket({required this.range, required this.counts});
}

final class EmotionPair {
  final String firstId;
  final String secondId;
  final List<String> mindIds;

  const EmotionPair({required this.firstId, required this.secondId, required this.mindIds});

  int get count => mindIds.length;
}

enum DayPart { night, morning, afternoon, evening }

final class EmotionRhythm {
  /// `DateTime.monday` … `DateTime.sunday` → top-level emotion id → minds.
  final Map<int, Map<String, int>> byWeekday;
  final Map<DayPart, Map<String, int>> byDayPart;
  final Map<int, List<String>> weekdayMindIds;
  final Map<DayPart, List<String>> dayPartMindIds;

  const EmotionRhythm({
    required this.byWeekday,
    required this.byDayPart,
    required this.weekdayMindIds,
    required this.dayPartMindIds,
  });

  bool get isEmpty => byWeekday.isEmpty;

  static String? dominant(Map<String, int>? counts) {
    if (counts == null || counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}

final class StreakInsight {
  final int current;
  final int longest;

  /// False while today has no mind yet; the streak still counts until the day ends.
  final bool isTodayDone;

  const StreakInsight({required this.current, required this.longest, required this.isTodayDone});
}

final class OnThisDayGroup {
  final int yearsAgo;
  final int dayIndex;
  final List<String> mindIds;

  const OnThisDayGroup({required this.yearsAgo, required this.dayIndex, required this.mindIds});
}

final class MediaInsight {
  final int libraryPhotos;
  final int libraryVideos;
  final int audioMinds;
  final int videoMinds;

  /// Root minds and reflections with a round video, newest first.
  final List<String> roundVideoMindIds;

  const MediaInsight({
    required this.libraryPhotos,
    required this.libraryVideos,
    required this.audioMinds,
    required this.videoMinds,
    required this.roundVideoMindIds,
  });
}

final class InsightsReport {
  final InsightsPeriod period;
  final InsightsCounters counters;
  final BrightestSegment? brightest;
  final List<EmotionShare> emotionShares;
  final List<EmotionTrendBucket> emotionTrend;
  final List<EmotionPair> emotionPairs;
  final EmotionRhythm emotionRhythm;
  final StreakInsight streak;
  final Map<int, int> heatmap;
  final List<int> mindsByHour;
  final List<OnThisDayGroup> onThisDay;
  final MediaInsight media;

  const InsightsReport({
    required this.period,
    required this.counters,
    required this.brightest,
    required this.emotionShares,
    required this.emotionTrend,
    required this.emotionPairs,
    required this.emotionRhythm,
    required this.streak,
    required this.heatmap,
    required this.mindsByHour,
    required this.onThisDay,
    required this.media,
  });
}
