import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/services/emotions/frequent_emotions.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';

Emotion _emotion(String id, {String? emoji}) => Emotion(
  id: id,
  title: id,
  emoji: emoji ?? id,
  parentId: null,
  isArchived: false,
  orderIndex: 0,
  creationDate: DateTime.utc(2026),
);

Mind _mind(List<String> emotionIds, {String? rootId}) => Mind(
  id: emotionIds.join(),
  note: '',
  dayIndex: 0,
  sortIndex: 0,
  creationDate: DateTime.utc(2026),
  rootId: rootId,
  emotionIds: emotionIds,
);

void main() {
  group('FrequentEmotions', () {
    final a = _emotion('a'), b = _emotion('b'), c = _emotion('c');

    test('orders used emotions by usage and tops up with the fallback', () {
      final picked = FrequentEmotions.pick(
        minds: [_mind(['b']), _mind(['b', 'a']), _mind(['b'])],
        activeEmotions: [a, b, c],
        fallback: [c, a],
        limit: 3,
      );
      expect(picked, [b, a, c]);
    });

    test('ignores ids of inactive emotions and respects the limit', () {
      final picked = FrequentEmotions.pick(
        minds: [_mind(['archived', 'a'])],
        activeEmotions: [a],
        fallback: [b, c],
        limit: 2,
      );
      expect(picked, [a, b]);
    });
  });
}
