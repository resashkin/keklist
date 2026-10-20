import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:keklist/domain/repositories/mind/object/mind_object.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';

part 'mind.g.dart';

@JsonSerializable()
final class Mind with EquatableMixin {
  final String id;
  @JsonKey(name: 'emoji')
  final String? legacyEmoji;
  final String note; // TODO: rename to rawNote
  final int dayIndex;
  final DateTime creationDate;
  final int sortIndex;
  final String? rootId;
  final List<String> emotionIds;

  @override
  bool? get stringify => true;

  String get plainNote => noteContent.plainText;
  MindNoteContent get noteContent => MindNoteContent.parse(note);
  List<MindNoteAudio> get audioNotes => noteContent.audioPieces;

  Mind({
    required this.id,
    required this.note,
    this.legacyEmoji,
    required this.dayIndex,
    required this.creationDate,
    required this.sortIndex,
    required this.rootId,
    this.emotionIds = const [],
  });

  // JsonSerializable
  factory Mind.fromJson(Map<String, dynamic> json) => _$MindFromJson(json);
  Map<String, dynamic> toJson() => _$MindToJson(this);

  @override
  List<Object?> get props => [
        id,
        legacyEmoji,
        note,
        sortIndex,
        dayIndex,
        rootId,
        emotionIds,
        creationDate.millisecondsSinceEpoch,
      ];

  Map<String, dynamic> toShortJson() => {
        'uuid': id,
        'emoji': legacyEmoji ?? '',
        'note': note,
        'day_index': dayIndex,
        'sort_index': sortIndex,
      };

  /// Positional, header-less row. Columns are only ever appended: readers guard
  /// on length, so an older build ignores trailing fields it does not know.
  /// Ids are joined with `,` because the CSV field delimiter is `;`.
  List<String> toCSVEntry() => [
        id,
        legacyEmoji ?? '',
        note,
        dayIndex.toString(),
        sortIndex.toString(),
        creationDate.toString(),
        rootId?.toString() ?? "null",
        emotionIds.join(','),
      ];

  /// Parses a [toCSVEntry] row; throws on malformed numeric or date columns.
  factory Mind.fromCSVEntry(List<dynamic> row) {
    final String legacyEmoji = row[1].toString().trim();
    return Mind(
      id: row[0].toString(),
      legacyEmoji: legacyEmoji.isEmpty ? null : legacyEmoji,
      note: row[2].toString(),
      dayIndex: int.parse(row[3].toString()),
      sortIndex: int.parse(row[4].toString()),
      creationDate: DateTime.parse(row[5].toString()),
      rootId: row[6].toString() == 'null' ? null : row[6].toString(),
      emotionIds: emotionIdsFromCSVEntry(row),
    );
  }

  /// Parses the emotion id column of a [toCSVEntry] row, tolerating rows written
  /// before the column existed.
  static List<String> emotionIdsFromCSVEntry(List<dynamic> row) {
    if (row.length <= 7) return const [];
    return row[7].toString().split(',').map((id) => id.trim()).where((id) => id.isNotEmpty).toList();
  }

  Mind copyWith({
    String? id,
    String? note,
    int? dayIndex,
    DateTime? creationDate,
    int? sortIndex,
    String? rootId,
    List<String>? emotionIds,
  }) {
    return Mind(
      id: id ?? this.id,
      legacyEmoji: legacyEmoji,
      note: note ?? this.note,
      dayIndex: dayIndex ?? this.dayIndex,
      creationDate: creationDate ?? this.creationDate,
      sortIndex: sortIndex ?? this.sortIndex,
      rootId: rootId ?? this.rootId,
      emotionIds: emotionIds ?? this.emotionIds,
    );
  }

  MindObject toObject() => MindObject()
    ..id = id
    ..legacyEmoji = legacyEmoji
    ..note = note
    ..dayIndex = dayIndex
    ..creationDate = creationDate
    ..sortIndex = sortIndex
    ..rootId = rootId
    ..emotionIds = emotionIds;

  Mind copyWithNoteContent(MindNoteContent content) => copyWith(note: content.toRawNoteString());
  Mind appendAudioNote(String path, {String? separator, double? durationSeconds}) =>
      copyWithNoteContent(noteContent.copyWithAppendedAudio(path, separator: separator, durationSeconds: durationSeconds));
}
