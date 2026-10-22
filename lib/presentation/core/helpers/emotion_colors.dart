import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:material_ui/material_ui.dart';

// Top-level emotions take these in their order; the first five suit the starter set.
const List<Color> kEmotionPalette = [
  Color(0xFFFF6B6B),
  Color(0xFF9B8CFF),
  Color(0xFF5AC8FA),
  Color(0xFFFFCC4D),
  Color(0xFFFF7EB6),
  Color(0xFF4CD9A6),
  Color(0xFFFF9F45),
  Color(0xFF8E9AAF),
];

/// A palette color per root emotion, in their order; every child emotion takes its root's color.
Map<String, Color> emotionColorsOf(List<Emotion> emotions) {
  final List<Emotion> roots = emotions.where((emotion) => emotion.parentId == null).toList()
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  final Map<String, Color> colors = {
    for (int i = 0; i < roots.length; i++) roots[i].id: kEmotionPalette[i % kEmotionPalette.length],
  };
  final Map<String, Emotion> byId = {for (final Emotion emotion in emotions) emotion.id: emotion};
  for (final Emotion emotion in emotions) {
    Emotion current = emotion;
    final Set<String> seen = {};
    while (current.parentId != null && seen.add(current.id) && byId[current.parentId] != null) {
      current = byId[current.parentId]!;
    }
    colors.putIfAbsent(emotion.id, () => colors[current.id] ?? kEmotionPalette.last);
  }
  return colors;
}
