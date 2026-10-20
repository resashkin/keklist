import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';

part 'media_day_index_object.g.dart';

@HiveType(typeId: 5)
final class MediaDayIndexObject extends HiveObject {
  @HiveField(0)
  late int dayIndex;

  @HiveField(1)
  late int photoCount;

  @HiveField(2)
  late int videoCount;

  @HiveField(3, defaultValue: <String>[])
  late List<String> previewIds;

  MediaDayIndexObject();

  MediaDayIndex toEntry() =>
      MediaDayIndex(dayIndex: dayIndex, photoCount: photoCount, videoCount: videoCount, previewIds: previewIds);

  static MediaDayIndexObject fromEntry(MediaDayIndex entry) => MediaDayIndexObject()
    ..dayIndex = entry.dayIndex
    ..photoCount = entry.photoCount
    ..videoCount = entry.videoCount
    ..previewIds = entry.previewIds;
}
