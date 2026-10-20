import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';

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

void main() {
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
      final DayFeedMind evening = DayFeedMind(mind: _mind(id: 'evening', creationDate: DateTime(2026, 1, 1, 20)), reflectionCount: 0);
      final DayFeedMind morning = DayFeedMind(mind: _mind(id: 'morning', creationDate: DateTime(2026, 1, 1, 8)), reflectionCount: 0);
      final DayFeedMind noon = DayFeedMind(mind: _mind(id: 'noon', creationDate: DateTime(2026, 1, 1, 12)), reflectionCount: 0);

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
