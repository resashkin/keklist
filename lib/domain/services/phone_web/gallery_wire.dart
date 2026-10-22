import 'package:keklist/domain/services/media_index/media_day_index.dart';

/// JSON of the phone's gallery as the web version receives it; compact because a library has thousands of items.
abstract final class GalleryWire {
  static List<Object> assetToJson(GalleryAssetInfo asset) => [
    asset.id,
    asset.createDate.millisecondsSinceEpoch,
    asset.modifiedDate.millisecondsSinceEpoch,
    asset.isVideo ? 1 : 0,
    asset.width,
    asset.height,
    asset.durationSeconds,
  ];

  static GalleryAssetInfo assetFromJson(List<dynamic> json) => GalleryAssetInfo(
    id: json[0] as String,
    createDate: DateTime.fromMillisecondsSinceEpoch(json[1] as int),
    modifiedDate: DateTime.fromMillisecondsSinceEpoch(json[2] as int),
    isVideo: json[3] == 1,
    width: json[4] as int,
    height: json[5] as int,
    durationSeconds: json[6] as int,
  );

  static Map<String, Object?> indexToJson(MediaIndexMeta meta, Iterable<MediaDayIndex> days) => {
    'complete': meta.isComplete,
    'libraryCount': meta.libraryCount,
    'lastScan': meta.lastScanDate?.millisecondsSinceEpoch,
    'days': [
      for (final MediaDayIndex day in days)
        [day.dayIndex, day.photoCount, day.videoCount, day.assets.map(assetToJson).toList()],
    ],
  };

  static (MediaIndexMeta, List<MediaDayIndex>) indexFromJson(Map<String, dynamic> json) {
    final int? lastScan = json['lastScan'] as int?;
    return (
      MediaIndexMeta(
        isComplete: json['complete'] as bool,
        libraryCount: json['libraryCount'] as int,
        lastScanDate: lastScan == null ? null : DateTime.fromMillisecondsSinceEpoch(lastScan),
      ),
      [
        for (final List<dynamic> day in (json['days'] as List<dynamic>).cast<List<dynamic>>())
          MediaDayIndex(
            dayIndex: day[0] as int,
            photoCount: day[1] as int,
            videoCount: day[2] as int,
            assets: [
              for (final List<dynamic> asset in (day[3] as List<dynamic>).cast<List<dynamic>>()) assetFromJson(asset),
            ],
          ),
      ],
    );
  }

  static String thumbnailPath(String id) => '/gallery/thumb?id=${Uri.encodeQueryComponent(id)}';
  static String originalPath(String id) => '/gallery/full?id=${Uri.encodeQueryComponent(id)}';
}
