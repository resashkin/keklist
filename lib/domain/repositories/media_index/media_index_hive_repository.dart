import 'dart:async';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:keklist/domain/repositories/media_index/media_index_repository.dart';
import 'package:keklist/domain/repositories/media_index/object/media_day_index_object.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';

/// Days are keyed by `dayIndex`; the meta lives in a separate untyped box.
final class MediaIndexHiveRepository implements MediaIndexRepository {
  // Bumping it makes an older index incomplete, so the next sync does a full scan.
  static const int formatVersion = 2;
  static const String _formatVersionKey = 'formatVersion';
  static const String _isCompleteKey = 'isComplete';
  static const String _libraryCountKey = 'libraryCount';
  static const String _lastScanKey = 'lastScanMillis';

  Box<MediaDayIndexObject>? _openedDaysBox;
  Box? _openedMetaBox;

  @override
  late final Future<void> ready;

  /// The boxes open in the background, so app start never waits for the index; until then it reads as empty.
  MediaIndexHiveRepository({required Future<Box<MediaDayIndexObject>> daysBox, required Future<Box> metaBox}) {
    ready = Future.wait([daysBox, metaBox]).then((boxes) {
      _openedDaysBox = boxes[0] as Box<MediaDayIndexObject>;
      _openedMetaBox = boxes[1];
    });
  }

  Box<MediaDayIndexObject> get _daysBox => _openedDaysBox!;
  Box get _metaBox => _openedMetaBox!;
  bool get _isOpen => _openedDaysBox != null && _openedMetaBox != null;

  @override
  MediaIndexMeta get meta {
    if (!_isOpen) return MediaIndexMeta.empty;
    final int? lastScanMillis = _metaBox.get(_lastScanKey) as int?;
    return MediaIndexMeta(
      isComplete:
          _metaBox.get(_isCompleteKey, defaultValue: false) as bool &&
          _metaBox.get(_formatVersionKey) == formatVersion,
      libraryCount: _metaBox.get(_libraryCountKey, defaultValue: 0) as int,
      lastScanDate: lastScanMillis == null ? null : DateTime.fromMillisecondsSinceEpoch(lastScanMillis),
    );
  }

  @override
  MediaDayIndex? entryFor(int dayIndex) => _isOpen ? _daysBox.get(dayIndex)?.toEntry() : null;

  @override
  Iterable<MediaDayIndex> get entries => _isOpen ? _daysBox.values.map((object) => object.toEntry()) : const [];

  @override
  Future<void> replaceAll({required Iterable<MediaDayIndex> entries, required MediaIndexMeta meta}) async {
    await ready;
    await _daysBox.clear();
    await _daysBox.putAll({for (final MediaDayIndex entry in entries) entry.dayIndex: MediaDayIndexObject.fromEntry(entry)});
    await updateMeta(meta);
  }

  @override
  Future<void> putDays({required Iterable<MediaDayIndex> entries, required Iterable<int> emptyDayIndexes}) async {
    await ready;
    await _daysBox.putAll({for (final MediaDayIndex entry in entries) entry.dayIndex: MediaDayIndexObject.fromEntry(entry)});
    await _daysBox.deleteAll(emptyDayIndexes);
  }

  @override
  Future<void> updateMeta(MediaIndexMeta meta) async {
    await ready;
    await _metaBox.putAll({
      _formatVersionKey: formatVersion,
      _isCompleteKey: meta.isComplete,
      _libraryCountKey: meta.libraryCount,
      _lastScanKey: meta.lastScanDate?.millisecondsSinceEpoch,
    });
  }
}
