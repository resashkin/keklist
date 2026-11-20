import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/photo_fingerprint.dart';

void main() {
  final DateTime takenAt = DateTime.utc(2026, 11, 19, 14, 3, 27);

  group('PhotoFingerprint', () {
    test('key round-trips', () {
      final PhotoFingerprint fingerprint = PhotoFingerprint.of(takenAt, width: 4032, height: 3024);

      expect(fingerprint.key, 'photo:${takenAt.millisecondsSinceEpoch ~/ 1000}:4032x3024');
      final PhotoFingerprint parsed = PhotoFingerprint.parse(fingerprint.key)!;
      expect(parsed.takenAtSeconds, fingerprint.takenAtSeconds);
      expect((parsed.width, parsed.height), (4032, 3024));
      expect(PhotoFingerprint.parse('asset_123'), isNull);
    });

    test('the same photo matches, rotated or in another time zone', () {
      final PhotoFingerprint photo = PhotoFingerprint.of(takenAt, width: 4032, height: 3024);

      expect(photo.matches(PhotoFingerprint.of(takenAt, width: 3024, height: 4032)), isTrue);
      expect(
        photo.matches(PhotoFingerprint.of(takenAt.add(const Duration(hours: 3)), width: 4032, height: 3024)),
        isTrue,
      );
      expect(photo.matches(PhotoFingerprint.of(takenAt.add(const Duration(minutes: 330)))), isTrue);
    });

    test('another photo does not match', () {
      final PhotoFingerprint photo = PhotoFingerprint.of(takenAt, width: 4032, height: 3024);

      expect(
        photo.matches(PhotoFingerprint.of(takenAt.add(const Duration(seconds: 1)), width: 4032, height: 3024)),
        isFalse,
      );
      expect(photo.matches(PhotoFingerprint.of(takenAt, width: 1920, height: 1080)), isFalse);
      expect(
        photo.matches(PhotoFingerprint.of(takenAt.add(const Duration(hours: 15)), width: 4032, height: 3024)),
        isFalse,
      );
    });

    test('joins an existing thread, preferring the exact one', () {
      final PhotoFingerprint photo = PhotoFingerprint.of(takenAt, width: 4032, height: 3024);
      final String shifted = PhotoFingerprint.of(takenAt.add(const Duration(hours: 2)), width: 4032, height: 3024).key;
      final String other = PhotoFingerprint.of(takenAt, width: 100, height: 100).key;

      expect(photo.rootAmong([other]), photo.key);
      expect(photo.rootAmong([other, shifted]), shifted);
      expect(photo.rootAmong([shifted, photo.key]), photo.key);
    });

    test('an empty reflection on a fingerprint is an emotion tag', () {
      Mind reflection(String root, String note) => Mind(
        id: 'id',
        note: note,
        dayIndex: 1,
        creationDate: DateTime(2026),
        sortIndex: 0,
        rootId: root,
        emotionIds: const ['joy'],
      );

      expect(reflection(PhotoFingerprint.of(takenAt).key, '').isEmotionTag, isTrue);
      expect(reflection(PhotoFingerprint.of(takenAt).key, 'nice').isEmotionTag, isFalse);
    });
  });
}
