import 'dart:math';

import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';

/// The header a run of tiles goes under when a feed is grouped.
enum DayFeedSectionKind { minds, gallery, night, morning, afternoon, evening }

final class DayFeedSection {
  final DayFeedSectionKind? kind;
  final List<DayFeedItem> items;

  const DayFeedSection({required this.kind, required this.items});
}

final class DayFeedLayout {
  static const double cellSpacing = 4.0;
  static const double horizontalPadding = 8.0;
  static const Duration photoStoryDuration = Duration(seconds: 5);
  static const Duration mindStoryBaseDuration = Duration(seconds: 3);
  static const Duration mindStoryPerCharacter = Duration(milliseconds: 60);
  static const Duration mindStoryMaxDuration = Duration(seconds: 12);

  static List<DayFeedMind> mindItemsForDay({required int dayIndex, required Iterable<Mind> allMinds}) {
    final Map<String, MindReflections> reflections = MindReflections.countAll(allMinds);
    return allMinds
        .where((mind) => mind.dayIndex == dayIndex && mind.rootId == null)
        .map((mind) => DayFeedMind(mind: mind, reflections: reflections[mind.id] ?? const MindReflections()))
        .toList();
  }

  static List<DayFeedItem> merge({required List<DayFeedItem> minds, required List<DayFeedItem> media}) =>
      [...minds, ...media]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  /// Splits time-ordered [items] into sections for [grouping], each ordered by [sortOrder].
  static List<DayFeedSection> arrange(
    List<DayFeedItem> items, {
    required FeedSortOrder sortOrder,
    required FeedGrouping grouping,
  }) {
    final List<DayFeedItem> minds = items.whereType<DayFeedMind>().toList();
    final List<DayFeedItem> media = items.where((item) => item is! DayFeedMind).toList();
    List<DayFeedItem> sorted(List<DayFeedItem> part) => switch (sortOrder) {
      FeedSortOrder.time => part,
      FeedSortOrder.mindsFirst => [...part.whereType<DayFeedMind>(), ...part.where((item) => item is! DayFeedMind)],
      FeedSortOrder.mediaFirst => [...part.where((item) => item is! DayFeedMind), ...part.whereType<DayFeedMind>()],
    };
    final List<DayFeedSection> sections = switch (grouping) {
      FeedGrouping.none => [DayFeedSection(kind: null, items: sorted(items))],
      FeedGrouping.type => [
        if (sortOrder == FeedSortOrder.mediaFirst) DayFeedSection(kind: DayFeedSectionKind.gallery, items: media),
        DayFeedSection(kind: DayFeedSectionKind.minds, items: minds),
        if (sortOrder != FeedSortOrder.mediaFirst) DayFeedSection(kind: DayFeedSectionKind.gallery, items: media),
      ],
      FeedGrouping.timeOfDay => [
        for (final DayFeedSectionKind kind in const [
          DayFeedSectionKind.night,
          DayFeedSectionKind.morning,
          DayFeedSectionKind.afternoon,
          DayFeedSectionKind.evening,
        ])
          DayFeedSection(kind: kind, items: sorted(items.where((item) => timeOfDayOf(item.timestamp) == kind).toList())),
      ],
    };
    return sections.where((section) => section.items.isNotEmpty).toList();
  }

  static List<DayFeedItem> arrangedItems(
    List<DayFeedItem> items, {
    required FeedSortOrder sortOrder,
    required FeedGrouping grouping,
  }) => [
    for (final DayFeedSection section in arrange(items, sortOrder: sortOrder, grouping: grouping)) ...section.items,
  ];

  static DayFeedSectionKind timeOfDayOf(DateTime time) => switch (time.hour) {
    < 5 => DayFeedSectionKind.night,
    < 12 => DayFeedSectionKind.morning,
    < 17 => DayFeedSectionKind.afternoon,
    _ => DayFeedSectionKind.evening,
  };

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
