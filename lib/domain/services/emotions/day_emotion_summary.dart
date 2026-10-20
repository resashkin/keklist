import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';

/// Unique emotion emojis of a day's root minds, plus whether any of them has no emotion.
final class DayEmotionSummary {
  static const String untaggedMark = '•';

  final List<String> emojis;
  final bool hasUntaggedMinds;

  const DayEmotionSummary({required this.emojis, required this.hasUntaggedMinds});

  factory DayEmotionSummary.of(Iterable<Mind> minds, Emotion? Function(String id) emotionById) {
    final Set<String> emojis = {};
    bool hasUntaggedMinds = false;
    for (final Mind mind in minds.where((mind) => mind.rootId == null)) {
      final Iterable<Emotion> emotions = mind.emotionIds.map(emotionById).whereType<Emotion>();
      if (emotions.isEmpty) hasUntaggedMinds = true;
      emojis.addAll(emotions.map((emotion) => emotion.emoji));
    }
    return DayEmotionSummary(emojis: emojis.toList(), hasUntaggedMinds: hasUntaggedMinds);
  }

  String get text => [...emojis, if (hasUntaggedMinds) untaggedMark].join(' ');
}
