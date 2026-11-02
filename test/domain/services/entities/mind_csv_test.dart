import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/services/entities/mind.dart';

Mind _mind({String? legacyEmoji, List<String> emotionIds = const []}) => Mind(
  id: 'id',
  legacyEmoji: legacyEmoji,
  note: 'note',
  dayIndex: 12,
  sortIndex: 3,
  creationDate: DateTime.utc(2026, 1, 2, 3, 4, 5),
  rootId: 'root',
  emotionIds: emotionIds,
);

void main() {
  test('CSV round-trip keeps legacy emoji and emotions', () {
    final Mind mind = _mind(legacyEmoji: '😄', emotionIds: ['a', 'b']);
    expect(Mind.fromCSVEntry(mind.toCSVEntry()), mind);
  });

  test('a mind without legacy emoji writes an empty emoji column and reads back null', () {
    final List<String> row = _mind().toCSVEntry();
    expect(row[1], '');
    expect(Mind.fromCSVEntry(row).legacyEmoji, isNull);
  });

  test('rows written before the emotion column parse without emotions', () {
    final List<String> row = _mind(legacyEmoji: '😄', emotionIds: ['a']).toCSVEntry().sublist(0, 7);
    expect(Mind.fromCSVEntry(row).emotionIds, isEmpty);
  });
}
