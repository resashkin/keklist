import 'package:keklist/domain/repositories/emotion/emotion_repository.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/emotion_seed.dart';
import 'package:uuid/uuid.dart';

/// Creates the starter emotions in the user's language. See ADR-0003.
abstract final class EmotionSeeder {
  /// Requires both that seeding never ran and that the store is empty: the flag
  /// alone would duplicate onto an existing set installed before the flag
  /// existed, and the emptiness check alone would resurrect deleted emotions.
  static Future<void> seedIfNeeded({
    required EmotionRepository emotionRepository,
    required SettingsRepository settingsRepository,
  }) async {
    if (settingsRepository.value.hasSeededEmotions) return;
    final existing = await emotionRepository.obtainEmotions();
    if (existing.isNotEmpty) {
      await settingsRepository.updateHasSeededEmotions(true);
      return;
    }

    final seeds = EmotionSeed.forLanguage(settingsRepository.value.language);
    final now = DateTime.now().toUtc();
    const Uuid uuid = Uuid();
    final emotions = <Emotion>[
      for (int i = 0; i < seeds.length; i++)
        Emotion(
          id: uuid.v4(),
          title: seeds[i].title,
          emoji: seeds[i].emoji,
          parentId: null,
          isArchived: false,
          orderIndex: i,
          creationDate: now,
        ),
    ];
    await emotionRepository.createEmotions(emotions: emotions);
    await settingsRepository.updateHasSeededEmotions(true);
  }
}
