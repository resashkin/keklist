import 'dart:async';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:keklist/domain/repositories/media_index/media_index_repository.dart';
import 'package:keklist/domain/repositories/media_index/object/media_day_index_object.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';

/// Days are keyed by `dayIndex`; the meta lives in a separate untyped box.
final class MediaIndexHiveRepository implements MediaIndexRepository {
  static const String _isCompleteKey = 'isComplete';
  static const String _libraryCountKey = 'libraryCount';
  static const String _lastScanKey = 'lastScanMillis';

  final Box<MediaDayIndexObject> _daysBox;
  final Box _metaBox;

  MediaIndexHiveRepository({required Box<MediaDayIndexObject> daysBox, required Box metaBox})
    : _daysBox = daysBox,
      _metaBox = metaBox;

  @override
  MediaIndexMeta get meta {
    final int? lastScanMillis = _metaBox.get(_lastScanKey) as int?;
    return MediaIndexMeta(
      isComplete: _metaBox.get(_isCompleteKey, defaultValue: false) as bool,
      libraryCount: _metaBox.get(_libraryCountKey, defaultValue: 0) as int,
      lastScanDate: lastScanMillis == null ? null : DateTime.fromMillisecondsSinceEpoch(lastScanMillis),
    );
  }

  @override
  MediaDayIndex? entryFor(int dayIndex) => _daysBox.get(dayIndex)?.toEntry();

  @override
  Iterable<MediaDayIndex> get entries => _daysBox.values.map((object) => object.toEntry());

  @override
  Future<void> replaceAll({required Iterable<MediaDayIndex> entries, required MediaIndexMeta meta}) async {
    await _daysBox.clear();
    await _daysBox.putAll({for (final MediaDayIndex entry in entries) entry.dayIndex: MediaDayIndexObject.fromEntry(entry)});
    await updateMeta(meta);
  }

  @override
  Future<void> putDays({required Iterable<MediaDayIndex> entries, required Iterable<int> emptyDayIndexes}) async {
    await _daysBox.putAll({for (final MediaDayIndex entry in entries) entry.dayIndex: MediaDayIndexObject.fromEntry(entry)});
    await _daysBox.deleteAll(emptyDayIndexes);
  }

  @override
  Future<void> updateMeta(MediaIndexMeta meta) => _metaBox.putAll({
    _isCompleteKey: meta.isComplete,
    _libraryCountKey: meta.libraryCount,
    _lastScanKey: meta.lastScanDate?.millisecondsSinceEpoch,
  });
}
