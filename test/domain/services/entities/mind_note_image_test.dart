import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/core/helpers/mind_text_edit.dart';

void main() {
  group('Images in a note', () {
    test('parse and serialize keep images in order around the text', () {
      const String raw = '<kekimage path="image/a.jpg"/><kekimage path="image/b.png"/>\nDinner with Anna';

      final MindNoteContent content = MindNoteContent.parse(raw);

      expect(content.imagePieces.map((image) => image.appRelativePath), ['image/a.jpg', 'image/b.png']);
      expect(content.plainText.trim(), 'Dinner with Anna');
      expect(content.hasImages, isTrue);
      expect(content.hasMedia, isTrue);
      expect(content.toRawNoteString(), raw);
    });

    test('a note can be only images', () {
      final String raw = MindNoteContent.fromPieces([
        const MindNoteImage(appRelativePath: 'image/a.jpg'),
      ]).toRawNoteString();

      final MindNoteContent content = MindNoteContent.parse(raw);

      expect(content.plainText, isEmpty);
      expect(content.imagePieces.single.appRelativePath, 'image/a.jpg');
    });

    test('image files are listed for deletion and backup', () {
      final MindNoteContent content = MindNoteContent.parse(
        '<kekimage path="image/a.jpg"/><kekaudio path="audio/x.m4a" duration="3.0"/>',
      );

      expect(content.mediaFilePaths, containsAll(['image/a.jpg', 'audio/x.m4a']));
    });

    test('an image tag with an empty path is plain text', () {
      final MindNoteContent content = MindNoteContent.parse('<kekimage path=""/>');

      expect(content.imagePieces, isEmpty);
    });

    test('editing the text keeps the images', () {
      final Mind mind = Mind(
        id: 'm',
        note: '<kekimage path="image/a.jpg"/>\nold',
        dayIndex: 0,
        creationDate: DateTime(2026),
        sortIndex: 0,
        rootId: null,
        emotionIds: const [],
      );

      final Mind edited = mindWithText(mind, 'new');

      expect(edited.noteContent.imagePieces.single.appRelativePath, 'image/a.jpg');
      expect(edited.plainNote.trim(), 'new');
    });

    test('withoutMedia drops images', () {
      final MindNoteContent content = MindNoteContent.parse('<kekimage path="image/a.jpg"/>\ntext').withoutMedia();

      expect(content.hasImages, isFalse);
      expect(content.plainText.trim(), 'text');
    });

    test('a gallery video is told apart by its extension and keeps a preview next to it', () {
      const MindNoteImage video = MindNoteImage(appRelativePath: 'image/v.mp4');
      const MindNoteImage photo = MindNoteImage(appRelativePath: 'image/p.jpg');

      expect(video.isVideo, isTrue);
      expect(video.previewRelativePath, 'image/v.jpg');
      expect(photo.isVideo, isFalse);
      expect(photo.previewRelativePath, 'image/p.jpg');
    });

    test('media file paths include a video preview', () {
      final MindNoteContent content = MindNoteContent.parse('<kekimage path="image/v.mov"/><kekimage path="image/p.jpg"/>');

      expect(content.mediaFilePaths, ['image/v.mov', 'image/v.jpg', 'image/p.jpg']);
    });
  });
}
