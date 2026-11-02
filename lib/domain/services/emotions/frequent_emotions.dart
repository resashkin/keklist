import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';

abstract final class FrequentEmotions {
  /// Most-used active emotions first, topped up with [fallback] until [limit].
  static List<Emotion> pick({
    required Iterable<Mind> minds,
    required List<Emotion> activeEmotions,
    required List<Emotion> fallback,
    int limit = 6,
  }) {
    final Map<String, int> usage = {};
    for (final Mind mind in minds) {
      for (final String id in mind.emotionIds) {
        usage[id] = (usage[id] ?? 0) + 1;
      }
    }
    final List<Emotion> used = activeEmotions.where((emotion) => usage.containsKey(emotion.id)).toList()
      ..sort((a, b) => usage[b.id]!.compareTo(usage[a.id]!));
    final List<Emotion> result = used.take(limit).toList();
    for (final Emotion emotion in fallback) {
      if (result.length >= limit) break;
      if (!result.contains(emotion)) result.add(emotion);
    }
    return result;
  }
}
