import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/services/emotions/legacy_emoji_linker.dart';
import 'package:keklist/domain/services/entities/emotion.dart';
import 'package:keklist/domain/services/entities/mind.dart';

Emotion _emotion(String id, String emoji, {String? parentId, bool isArchived = false, int orderIndex = 0}) => Emotion(
  id: id,
  title: id,
  emoji: emoji,
  parentId: parentId,
  isArchived: isArchived,
  orderIndex: orderIndex,
  creationDate: DateTime.utc(2026),
);

Mind _mind(String id, String? legacyEmoji, {String? rootId, List<String> emotionIds = const []}) => Mind(
  id: id,
  legacyEmoji: legacyEmoji,
  note: id,
  dayIndex: 0,
  sortIndex: 0,
  creationDate: DateTime.utc(2026),
  rootId: rootId,
  emotionIds: emotionIds,
);

void main() {
  test('links a root mind to the active emotion with the same emoji', () {
    final linked = LegacyEmojiLinker.link(minds: [_mind('m', '😄')], emotions: [_emotion('joy', '😄')]);
    expect(linked.single.emotionIds, ['joy']);
    expect(linked.single.legacyEmoji, '😄');
  });

  test('leaves minds without a matching emotion untouched', () {
    expect(LegacyEmojiLinker.link(minds: [_mind('m', '🚀')], emotions: [_emotion('joy', '😄')]), isEmpty);
  });

  test('skips reflections, minds with emotions and minds without legacy emoji', () {
    final linked = LegacyEmojiLinker.link(
      minds: [
        _mind('reflection', '😄', rootId: 'root'),
        _mind('tagged', '😄', emotionIds: ['love']),
        _mind('empty', null),
      ],
      emotions: [_emotion('joy', '😄')],
    );
    expect(linked, isEmpty);
  });

  test('ignores archived emotions', () {
    expect(
      LegacyEmojiLinker.link(minds: [_mind('m', '😄')], emotions: [_emotion('joy', '😄', isArchived: true)]),
      isEmpty,
    );
  });

  test('prefers top-level emotions, then the lower orderIndex', () {
    final linked = LegacyEmojiLinker.link(
      minds: [_mind('m', '😄')],
      emotions: [
        _emotion('nested', '😄', parentId: 'root'),
        _emotion('second', '😄', orderIndex: 2),
        _emotion('first', '😄', orderIndex: 1),
      ],
    );
    expect(linked.single.emotionIds, ['first']);
  });

  test('matches emoji with and without a variation selector', () {
    final linked = LegacyEmojiLinker.link(minds: [_mind('m', '❤')], emotions: [_emotion('love', '❤️')]);
    expect(linked.single.emotionIds, ['love']);
  });
}
