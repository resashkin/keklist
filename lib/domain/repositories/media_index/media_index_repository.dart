import 'dart:async';

import 'package:keklist/domain/services/media_index/media_day_index.dart';

abstract class MediaIndexRepository {
  /// Completes once stored data is readable; reads before that see an empty index.
  Future<void> get ready;
  MediaIndexMeta get meta;
  MediaDayIndex? entryFor(int dayIndex);
  Iterable<MediaDayIndex> get entries;
  Iterable<int> get dayIndexes;
  FutureOr<void> replaceAll({required Iterable<MediaDayIndex> entries, required MediaIndexMeta meta});
  FutureOr<void> putDays({required Iterable<MediaDayIndex> entries, required Iterable<int> emptyDayIndexes});
  FutureOr<void> updateMeta(MediaIndexMeta meta);
}
