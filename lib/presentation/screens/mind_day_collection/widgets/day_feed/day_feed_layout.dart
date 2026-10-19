import 'dart:math';

import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';

final class DayFeedLayout {
  static const Duration photoStoryDuration = Duration(seconds: 5);
  static const Duration mindStoryBaseDuration = Duration(seconds: 3);
  static const Duration mindStoryPerCharacter = Duration(milliseconds: 60);
  static const Duration mindStoryMaxDuration = Duration(seconds: 12);

  static List<DayFeedMind> mindItemsForDay({required int dayIndex, required Iterable<Mind> allMinds}) {
    final Map<String, int> reflectionCounts = {};
    for (final Mind mind in allMinds) {
      final String? rootId = mind.rootId;
      if (rootId == null) continue;
      reflectionCounts[rootId] = (reflectionCounts[rootId] ?? 0) + 1;
    }
    return allMinds
        .where((mind) => mind.dayIndex == dayIndex && mind.rootId == null)
        .map((mind) => DayFeedMind(mind: mind, reflectionCount: reflectionCounts[mind.id] ?? 0))
        .toList();
  }

  static List<DayFeedItem> merge({required List<DayFeedItem> minds, required List<DayFeedItem> media}) =>
      [...minds, ...media]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  static List<List<int>> packIntoRows({
    required List<int> spans,
    required int columnCount,
  }) {
    final List<List<int>> rows = [];
    List<int> currentRow = [];
    int usedCells = 0;
    for (int index = 0; index < spans.length; index++) {
      final int span = min(spans[index], columnCount);
      if (usedCells + span > columnCount) {
        rows.add(currentRow);
        currentRow = [];
        usedCells = 0;
      }
      currentRow.add(index);
      usedCells += span;
    }
    if (currentRow.isNotEmpty) rows.add(currentRow);
    return rows;
  }

  static Duration mindStoryDuration(Mind mind) {
    final Duration readingTime = mindStoryPerCharacter * mind.plainNote.trim().length;
    final Duration total = mindStoryBaseDuration + readingTime;
    return total > mindStoryMaxDuration ? mindStoryMaxDuration : total;
  }
}
