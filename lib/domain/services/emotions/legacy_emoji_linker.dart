import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';

/// Tags old root minds with the emotion that shares their former main emoji.
/// See `documentation/MAIN_EMOJI_REMOVAL_IMPLEMENTATION.md`.
abstract final class LegacyEmojiLinker {
  /// Returns only the minds that changed. A mind is linked when it is a root
  /// mind without emotions and an active emotion has the same emoji; top-level
  /// emotions win over nested ones, then the lower `orderIndex`.
  static List<Mind> link({required Iterable<Mind> minds, required Iterable<Emotion> emotions}) {
    final Map<String, Emotion> emotionByEmoji = {};
    final List<Emotion> candidates = emotions.where((emotion) => !emotion.isArchived).toList()
      ..sort((a, b) {
        final int depth = (a.parentId == null ? 0 : 1).compareTo(b.parentId == null ? 0 : 1);
        return depth != 0 ? depth : a.orderIndex.compareTo(b.orderIndex);
      });
    for (final Emotion emotion in candidates) {
      emotionByEmoji.putIfAbsent(normalize(emotion.emoji), () => emotion);
    }

    final List<Mind> linked = [];
    for (final Mind mind in minds) {
      final String? legacyEmoji = mind.legacyEmoji;
      if (mind.rootId != null || mind.emotionIds.isNotEmpty || legacyEmoji == null) continue;
      final Emotion? emotion = emotionByEmoji[normalize(legacyEmoji)];
      if (emotion != null) linked.add(mind.copyWith(emotionIds: [emotion.id]));
    }
    return linked;
  }

  // "❤️" and "❤" are the same emoji with and without a variation selector.
  static String normalize(String emoji) => emoji.replaceAll(RegExp('[︎️]'), '').trim();
}
