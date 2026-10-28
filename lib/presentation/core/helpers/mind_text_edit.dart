import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';

/// Keeps the audio/video of the mind and replaces its text.
Mind mindWithText(Mind mind, String newText) {
  final List<BaseMindNotePiece> keptMedia = mind.noteContent.pieces
      .where((piece) => piece is MindNoteAudio || piece is MindNoteVideo)
      .toList();
  final String text = newText.trim();
  final MindNoteContent edited = MindNoteContent.fromPieces([
    ...keptMedia,
    if (text.isNotEmpty) MindNoteText(keptMedia.isEmpty ? text : '\n$text'),
  ]);
  return mind.copyWith(note: edited.toRawNoteString());
}
