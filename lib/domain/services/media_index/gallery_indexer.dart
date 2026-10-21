import 'dart:async';

import 'package:keklist/domain/repositories/media_index/media_index_repository.dart';
import 'package:keklist/domain/services/media_index/gallery_source.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';
import 'package:keklist/domain/services/media_index/media_day_index_builder.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';
import 'package:rxdart/rxdart.dart';

enum GalleryIndexStatus { unsupported, noAccess, idle, indexing, ready }

final class GalleryIndexProgress {
  final GalleryIndexStatus status;
  final int indexedCount;
  final int libraryCount;
  final DateTime? lastScanDate;

  const GalleryIndexProgress({
    required this.status,
    this.indexedCount = 0,
    this.libraryCount = 0,
    this.lastScanDate,
  });

  double? get fraction => libraryCount == 0 ? null : (indexedCount / libraryCount).clamp(0.0, 1.0);
}

/// Keeps a per-day photo/video index of the library. See
/// `documentation/GALLERY_INDEX_IMPLEMENTATION.md`.
final class GalleryIndexer {
  static const int pageSize = 500;

  final MediaIndexRepository _repository;
  final GallerySource _source;
  final BehaviorSubject<GalleryIndexProgress> _progress;
  Future<void>? _running;

  GalleryIndexer({required MediaIndexRepository repository, required GallerySource source})
    : _repository = repository,
      _source = source,
      _progress = BehaviorSubject.seeded(
        GalleryIndexProgress(
          status: source.isSupported ? GalleryIndexStatus.idle : GalleryIndexStatus.unsupported,
          indexedCount: repository.meta.libraryCount,
          libraryCount: repository.meta.libraryCount,
          lastScanDate: repository.meta.lastScanDate,
        ),
      ) {
    _repository.ready.then((_) => _emit(currentProgress.status));
  }

  Stream<GalleryIndexProgress> get progress => _progress.stream;
  GalleryIndexProgress get currentProgress => _progress.value;

  MediaDayIndex? entryFor(int dayIndex) => _repository.entryFor(dayIndex);
  Iterable<MediaDayIndex> get entries => _repository.entries;

  /// True when the index can vouch that [dayIndex] has no library media, so the
  /// day screen may skip the live query. Days on or after the last scan are never trusted.
  bool isKnownEmpty(int dayIndex) {
    final MediaIndexMeta meta = _repository.meta;
    final DateTime? lastScan = meta.lastScanDate;
    if (!meta.isComplete || lastScan == null) return false;
    return dayIndex < DateUtils.getDayIndex(from: lastScan) && _repository.entryFor(dayIndex) == null;
  }

  /// Full scan the first time, then only the days touched by modified assets.
  Future<void> sync() => _running ??= _sync(forceFull: false).whenComplete(() => _running = null);

  Future<void> rebuild() async {
    await _running;
    return _running ??= _sync(forceFull: true).whenComplete(() => _running = null);
  }

  /// Fresh result of a live day query from the day screen; keeps the index honest.
  Future<void> refreshDay(int dayIndex, Iterable<GalleryAssetInfo> assets) async {
    await _repository.ready;
    final MediaIndexMeta meta = _repository.meta;
    if (!meta.isComplete || _running != null) return;
    final int before = _repository.entryFor(dayIndex)?.totalCount ?? 0;
    final MediaDayIndex? entry = (MediaDayIndexBuilder()..addAll(assets)).buildDay(dayIndex);
    await _repository.putDays(entries: [?entry], emptyDayIndexes: [if (entry == null) dayIndex]);
    final int delta = (entry?.totalCount ?? 0) - before;
    if (delta != 0) {
      await _repository.updateMeta(
        MediaIndexMeta(isComplete: true, libraryCount: meta.libraryCount + delta, lastScanDate: meta.lastScanDate),
      );
    }
  }

  Future<void> _sync({required bool forceFull}) async {
    if (!_source.isSupported) return;
    await _repository.ready;
    if (!await _source.hasAccess()) {
      _emit(GalleryIndexStatus.noAccess);
      return;
    }
    final DateTime scanStart = DateTime.now();
    final int libraryCount = await _source.count();
    final MediaIndexMeta meta = _repository.meta;
    final bool isConsistent = !forceFull && meta.isComplete && meta.lastScanDate != null
        ? await _syncModified(since: meta.lastScanDate!, libraryCount: libraryCount)
        : false;
    if (!isConsistent) await _fullScan(libraryCount);
    await _repository.updateMeta(MediaIndexMeta(isComplete: true, libraryCount: libraryCount, lastScanDate: scanStart));
    _emit(GalleryIndexStatus.ready);
  }

  /// Returns false when the counts no longer add up (e.g. deletions) and a full scan is needed.
  Future<bool> _syncModified({required DateTime since, required int libraryCount}) async {
    final Set<int> touchedDays = (MediaDayIndexBuilder()..addAll(await _source.modifiedSince(since))).dayIndexes;
    int expectedCount = _repository.meta.libraryCount;
    final List<MediaDayIndex> updated = [];
    final List<int> emptied = [];
    for (final int dayIndex in touchedDays) {
      final MediaDayIndex? entry = (MediaDayIndexBuilder()..addAll(await _source.assetsOfDay(dayIndex))).buildDay(dayIndex);
      expectedCount += (entry?.totalCount ?? 0) - (_repository.entryFor(dayIndex)?.totalCount ?? 0);
      entry == null ? emptied.add(dayIndex) : updated.add(entry);
    }
    await _repository.putDays(entries: updated, emptyDayIndexes: emptied);
    return expectedCount == libraryCount;
  }

  Future<void> _fullScan(int libraryCount) async {
    final MediaDayIndexBuilder builder = MediaDayIndexBuilder();
    int indexed = 0;
    _emit(GalleryIndexStatus.indexing, indexedCount: 0, libraryCount: libraryCount);
    for (int page = 0; indexed < libraryCount; page++) {
      final List<GalleryAssetInfo> assets = await _source.page(page: page, size: pageSize);
      if (assets.isEmpty) break;
      builder.addAll(assets);
      indexed += assets.length;
      _emit(GalleryIndexStatus.indexing, indexedCount: indexed, libraryCount: libraryCount);
    }
    await _repository.replaceAll(
      entries: builder.build(),
      meta: MediaIndexMeta(isComplete: false, libraryCount: libraryCount, lastScanDate: null),
    );
  }

  void _emit(GalleryIndexStatus status, {int? indexedCount, int? libraryCount}) {
    if (_progress.isClosed) return;
    final MediaIndexMeta meta = _repository.meta;
    _progress.add(
      GalleryIndexProgress(
        status: status,
        indexedCount: indexedCount ?? meta.libraryCount,
        libraryCount: libraryCount ?? meta.libraryCount,
        lastScanDate: meta.lastScanDate,
      ),
    );
  }

  Future<void> dispose() => _progress.close();
}
