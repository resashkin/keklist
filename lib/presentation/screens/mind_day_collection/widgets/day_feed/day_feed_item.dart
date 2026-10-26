import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/mind_note_content.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/folder_media_item.dart';
import 'package:photo_manager/photo_manager.dart';

sealed class DayFeedItem {
  DateTime get timestamp;
  String get id;
}

/// The reflections of a mind by kind: written comments, round videos and audio notes.
final class MindReflections {
  final int comments;
  final int videos;
  final int audios;

  const MindReflections({this.comments = 0, this.videos = 0, this.audios = 0});

  int get total => comments + videos + audios;

  MindReflections adding(Mind reflection) {
    final MindNoteContent content = reflection.noteContent;
    if (content.hasVideo) return MindReflections(comments: comments, videos: videos + 1, audios: audios);
    if (content.hasAudio) return MindReflections(comments: comments, videos: videos, audios: audios + 1);
    return MindReflections(comments: comments + 1, videos: videos, audios: audios);
  }

  /// Reflections of every root mind among [minds], keyed by the root's id.
  static Map<String, MindReflections> countAll(Iterable<Mind> minds) {
    final Map<String, MindReflections> byRoot = {};
    for (final Mind mind in minds) {
      final String? rootId = mind.rootId;
      if (rootId != null) byRoot[rootId] = (byRoot[rootId] ?? const MindReflections()).adding(mind);
    }
    return byRoot;
  }
}

final class DayFeedMind extends DayFeedItem {
  final Mind mind;
  final MindReflections reflections;

  DayFeedMind({required this.mind, this.reflections = const MindReflections()});

  int get reflectionCount => reflections.total;

  @override
  DateTime get timestamp => mind.creationDate;

  @override
  String get id => 'mind_${mind.id}';
}

final class DayFeedAsset extends DayFeedItem {
  final AssetEntity asset;

  DayFeedAsset(this.asset);

  bool get isVideo => asset.type == AssetType.video;

  @override
  DateTime get timestamp => asset.createDateTime;

  @override
  String get id => idOf(asset.id);

  static String idOf(String assetId) => 'asset_$assetId';
}

final class DayFeedFolderMedia extends DayFeedItem {
  final FolderMediaItem item;

  @override
  final DateTime timestamp;

  DayFeedFolderMedia({required this.item, required this.timestamp});

  bool get isVideo => item.isVideo;

  @override
  String get id => switch (item) {
        FolderFileItem(:final file) => 'file_${file.path}',
        FolderSafItem(:final uri) => 'saf_$uri',
      };
}
