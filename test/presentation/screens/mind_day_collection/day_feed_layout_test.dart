import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/folder_media_item.dart';

Mind _mind({
  required String id,
  int dayIndex = 10,
  String? rootId,
  String note = '',
  DateTime? creationDate,
}) =>
    Mind(
      id: id,
      note: note,
      legacyEmoji: '🙂',
      dayIndex: dayIndex,
      creationDate: creationDate ?? DateTime(2026, 1, 1, 12),
      sortIndex: 0,
      rootId: rootId,
    );

DayFeedMind _mindAt(int hour) => DayFeedMind(mind: _mind(id: 'mind-$hour', creationDate: DateTime(2026, 1, 1, hour)));

DayFeedItem _photoAt(int hour) =>
    DayFeedFolderMedia(item: FolderFileItem(File('/photo-$hour.jpg')), timestamp: DateTime(2026, 1, 1, hour));

void main() {
  group('MindReflections', () {
    test('counts comments, videos and audio notes of each root', () {
      final Map<String, MindReflections> counts = MindReflections.countAll([
        _mind(id: 'root'),
        _mind(id: 'comment', rootId: 'root', note: 'nice'),
        _mind(id: 'video', rootId: 'root', note: '<kekvideo path="v.mp4" duration="3.0"/>'),
        _mind(id: 'audio', rootId: 'root', note: '<kekaudio path="a.m4a" duration="2.0"/>'),
        _mind(id: 'audio-2', rootId: 'root', note: 'hi<kekaudio path="b.m4a" duration="2.0"/>'),
      ]);

      final MindReflections root = counts['root']!;
      expect((root.comments, root.videos, root.audios, root.total), (1, 1, 2, 4));
    });
  });

  group('arrange', () {
    final List<DayFeedItem> day = [_mindAt(3), _photoAt(8), _mindAt(9), _photoAt(14), _mindAt(20)];
    List<String> ids(List<DayFeedItem> items) => items.map((item) => item.id).toList();

    test('keeps time order in one section by default', () {
      final List<DayFeedSection> sections =
          DayFeedLayout.arrange(day, sortOrder: FeedSortOrder.time, grouping: FeedGrouping.none);

      expect(sections.single.kind, isNull);
      expect(ids(sections.single.items), ids(day));
    });

    test('puts minds or media first, each in time order', () {
      expect(
        ids(DayFeedLayout.arrangedItems(day, sortOrder: FeedSortOrder.mindsFirst, grouping: FeedGrouping.none)),
        ids([day[0], day[2], day[4], day[1], day[3]]),
      );
      expect(
        ids(DayFeedLayout.arrangedItems(day, sortOrder: FeedSortOrder.mediaFirst, grouping: FeedGrouping.none)),
        ids([day[1], day[3], day[0], day[2], day[4]]),
      );
    });

    test('groups by type, the gallery first when media goes first', () {
      final List<DayFeedSection> byType =
          DayFeedLayout.arrange(day, sortOrder: FeedSortOrder.time, grouping: FeedGrouping.type);
      final List<DayFeedSection> mediaFirst =
          DayFeedLayout.arrange(day, sortOrder: FeedSortOrder.mediaFirst, grouping: FeedGrouping.type);

      expect(byType.map((section) => section.kind), [DayFeedSectionKind.minds, DayFeedSectionKind.gallery]);
      expect(mediaFirst.map((section) => section.kind), [DayFeedSectionKind.gallery, DayFeedSectionKind.minds]);
    });

    test('a single source goes without its header', () {
      final List<DayFeedSection> mindsOnly =
          DayFeedLayout.arrange([_mindAt(3), _mindAt(9)], sortOrder: FeedSortOrder.time, grouping: FeedGrouping.type);

      expect(mindsOnly.single.kind, isNull);
      expect(mindsOnly.single.items.length, 2);
    });

    test('groups by time of day and leaves out empty parts', () {
      final List<DayFeedSection> sections =
          DayFeedLayout.arrange(day, sortOrder: FeedSortOrder.mediaFirst, grouping: FeedGrouping.timeOfDay);

      expect(sections.map((section) => section.kind), [
        DayFeedSectionKind.night,
        DayFeedSectionKind.morning,
        DayFeedSectionKind.afternoon,
        DayFeedSectionKind.evening,
      ]);
      expect(ids(sections[1].items), ids([day[1], day[2]]));
    });

    test('arranging an arranged feed changes nothing', () {
      for (final FeedSortOrder sortOrder in FeedSortOrder.values) {
        for (final FeedGrouping grouping in FeedGrouping.values) {
          final List<DayFeedItem> once = DayFeedLayout.arrangedItems(day, sortOrder: sortOrder, grouping: grouping);
          expect(ids(DayFeedLayout.arrangedItems(once, sortOrder: sortOrder, grouping: grouping)), ids(once));
        }
      }
    });
  });

  group('mindItemsForDay', () {
    test('keeps root minds of the day and counts their reflections', () {
      final List<Mind> allMinds = [
        _mind(id: 'root'),
        _mind(id: 'reflection-1', rootId: 'root'),
        _mind(id: 'reflection-2', rootId: 'root', dayIndex: 11),
        _mind(id: 'other-day', dayIndex: 9),
      ];

      final List<DayFeedMind> items = DayFeedLayout.mindItemsForDay(dayIndex: 10, allMinds: allMinds);

      expect(items.map((item) => item.mind.id), ['root']);
      expect(items.single.reflectionCount, 2);
    });
  });

  group('merge', () {
    test('orders minds and media by timestamp, earliest first', () {
      final DayFeedMind evening = DayFeedMind(mind: _mind(id: 'evening', creationDate: DateTime(2026, 1, 1, 20)));
      final DayFeedMind morning = DayFeedMind(mind: _mind(id: 'morning', creationDate: DateTime(2026, 1, 1, 8)));
      final DayFeedMind noon = DayFeedMind(mind: _mind(id: 'noon', creationDate: DateTime(2026, 1, 1, 12)));

      final List<DayFeedItem> merged = DayFeedLayout.merge(minds: [evening, morning], media: [noon]);

      expect(merged, [morning, noon, evening]);
    });
  });

  group('packIntoRows', () {
    test('fills rows up to the column count', () {
      expect(DayFeedLayout.packIntoRows(spans: [1, 1, 1, 1, 1], columnCount: 4), [
        [0, 1, 2, 3],
        [4],
      ]);
    });

    test('moves a wide tile that does not fit to the next row, keeping order', () {
      expect(DayFeedLayout.packIntoRows(spans: [1, 1, 1, 2, 1], columnCount: 4), [
        [0, 1, 2],
        [3, 4],
      ]);
    });

    test('clamps spans wider than the grid', () {
      expect(DayFeedLayout.packIntoRows(spans: [5, 1], columnCount: 3), [
        [0],
        [1],
      ]);
    });
  });

  group('mindStoryDuration', () {
    test('adds reading time to the base duration', () {
      expect(DayFeedLayout.mindStoryDuration(_mind(id: 'short')), DayFeedLayout.mindStoryBaseDuration);
      expect(
        DayFeedLayout.mindStoryDuration(_mind(id: 'ten', note: '0123456789')),
        DayFeedLayout.mindStoryBaseDuration + DayFeedLayout.mindStoryPerCharacter * 10,
      );
    });

    test('is capped for long notes', () {
      expect(DayFeedLayout.mindStoryDuration(_mind(id: 'long', note: 'a' * 1000)), DayFeedLayout.mindStoryMaxDuration);
    });
  });
}
