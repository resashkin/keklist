import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';

part 'media_day_index_object.g.dart';

@HiveType(typeId: 5)
final class MediaDayIndexObject extends HiveObject {
  static const String _recordSeparator = '\n';
  static const String _fieldSeparator = '|';

  @HiveField(0)
  late int dayIndex;

  @HiveField(1)
  late int photoCount;

  @HiveField(2)
  late int videoCount;

  // @HiveField(3, defaultValue: <String>[]) — retired preview ids.

  // One string per day: decoding thousands of small objects on box open was slow.
  @HiveField(4, defaultValue: '')
  late String assetRecords;

  MediaDayIndexObject();

  MediaDayIndex toEntry() {
    final String records = assetRecords;
    return MediaDayIndex.lazy(
      dayIndex: dayIndex,
      photoCount: photoCount,
      videoCount: videoCount,
      decodeAssets: () => _decode(records),
    );
  }

  static MediaDayIndexObject fromEntry(MediaDayIndex entry) => MediaDayIndexObject()
    ..dayIndex = entry.dayIndex
    ..photoCount = entry.photoCount
    ..videoCount = entry.videoCount
    ..assetRecords = entry.assets.map(_encode).join(_recordSeparator);

  // Asset ids never contain the separators: Photos ids look like "UUID/L0/001".
  static String _encode(GalleryAssetInfo asset) => [
    asset.id,
    asset.createDate.millisecondsSinceEpoch,
    asset.modifiedDate.millisecondsSinceEpoch,
    asset.isVideo ? 1 : 0,
    asset.width,
    asset.height,
    asset.durationSeconds,
  ].join(_fieldSeparator);

  static List<GalleryAssetInfo> _decode(String records) {
    if (records.isEmpty) return const [];
    return [
      for (final String record in records.split(_recordSeparator))
        if (record.split(_fieldSeparator) case [
          final String id,
          final String created,
          final String modified,
          final String isVideo,
          final String width,
          final String height,
          final String duration,
        ])
          GalleryAssetInfo(
            id: id,
            createDate: DateTime.fromMillisecondsSinceEpoch(int.parse(created)),
            modifiedDate: DateTime.fromMillisecondsSinceEpoch(int.parse(modified)),
            isVideo: isVideo == '1',
            width: int.parse(width),
            height: int.parse(height),
            durationSeconds: int.parse(duration),
          ),
    ];
  }
}
