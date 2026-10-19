import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/presentation/screens/date_gallery/folder_media_item.dart';
import 'package:photo_manager/photo_manager.dart';

sealed class DayFeedItem {
  DateTime get timestamp;
  String get id;
}

final class DayFeedMind extends DayFeedItem {
  final Mind mind;
  final int reflectionCount;

  DayFeedMind({required this.mind, required this.reflectionCount});

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
  String get id => 'asset_${asset.id}';
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
