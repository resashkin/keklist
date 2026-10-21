import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/repositories/media_index/media_index_repository.dart';
import 'package:keklist/domain/services/media_index/gallery_indexer.dart';
import 'package:keklist/domain/services/media_index/gallery_source.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';
import 'package:keklist/domain/services/media_index/media_day_index_builder.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';

final class _MemoryRepository implements MediaIndexRepository {
  final Map<int, MediaDayIndex> days = {};
  MediaIndexMeta stored = MediaIndexMeta.empty;

  @override
  Future<void> get ready => Future.value();

  @override
  MediaIndexMeta get meta => stored;

  @override
  MediaDayIndex? entryFor(int dayIndex) => days[dayIndex];

  @override
  Iterable<MediaDayIndex> get entries => days.values;

  @override
  Iterable<int> get dayIndexes => days.keys;

  @override
  void replaceAll({required Iterable<MediaDayIndex> entries, required MediaIndexMeta meta}) {
    days
      ..clear()
      ..addAll({for (final e in entries) e.dayIndex: e});
    stored = meta;
  }

  @override
  void putDays({required Iterable<MediaDayIndex> entries, required Iterable<int> emptyDayIndexes}) {
    days.addAll({for (final e in entries) e.dayIndex: e});
    emptyDayIndexes.forEach(days.remove);
  }

  @override
  void updateMeta(MediaIndexMeta meta) => stored = meta;
}

final class _FakeSource implements GallerySource {
  final List<(GalleryAssetInfo, DateTime)> assets = [];
  bool access = true;
  int pageCalls = 0;

  void add(String id, DateTime created, {bool isVideo = false, DateTime? modified}) =>
      assets.add((GalleryAssetInfo(id: id, createDate: created, isVideo: isVideo), modified ?? created));

  @override
  bool get isSupported => true;

  @override
  Future<bool> hasAccess() async => access;

  @override
  Future<int> count() async => assets.length;

  @override
  Future<List<GalleryAssetInfo>> page({required int page, required int size}) async {
    pageCalls++;
    return assets.skip(page * size).take(size).map((a) => a.$1).toList();
  }

  @override
  Future<List<GalleryAssetInfo>> modifiedSince(DateTime date) async =>
      assets.where((a) => !a.$2.isBefore(date)).map((a) => a.$1).toList();

  @override
  Future<List<GalleryAssetInfo>> assetsOfDay(int dayIndex) async => assets
      .where((a) => DateUtils.getDayIndex(from: a.$1.createDate) == dayIndex)
      .map((a) => a.$1)
      .toList();
}

int _day(DateTime date) => DateUtils.getDayIndex(from: date);

void main() {
  final DateTime monday = DateTime(2026, 3, 2, 10);
  final DateTime tuesday = DateTime(2026, 3, 3, 10);

  late _MemoryRepository repository;
  late _FakeSource source;
  late GalleryIndexer indexer;

  setUp(() {
    repository = _MemoryRepository();
    source = _FakeSource();
    indexer = GalleryIndexer(repository: repository, source: source);
  });

  test('builder counts photos and videos per day and keeps every asset oldest first', () {
    final MediaDayIndexBuilder builder = MediaDayIndexBuilder()
      ..addAll([
        for (int i = 0; i < 10; i++)
          GalleryAssetInfo(id: 'p$i', createDate: monday.add(Duration(minutes: i)), isVideo: false),
        GalleryAssetInfo(id: 'v', createDate: monday.add(const Duration(hours: 1)), isVideo: true),
        GalleryAssetInfo(id: 'v', createDate: monday.add(const Duration(hours: 1)), isVideo: true),
      ]);
    final MediaDayIndex day = builder.buildDay(_day(monday))!;
    expect(day.photoCount, 10);
    expect(day.videoCount, 1);
    expect(day.assets.map((asset) => asset.id), [for (int i = 0; i < 10; i++) 'p$i', 'v']);
  });

  test('first sync scans the whole library', () async {
    source
      ..add('a', monday)
      ..add('b', monday, isVideo: true)
      ..add('c', tuesday);

    await indexer.sync();

    expect(repository.entryFor(_day(monday))!.photoCount, 1);
    expect(repository.entryFor(_day(monday))!.videoCount, 1);
    expect(repository.entryFor(_day(tuesday))!.totalCount, 1);
    expect(repository.meta.isComplete, true);
    expect(repository.meta.libraryCount, 3);
    expect(indexer.currentProgress.status, GalleryIndexStatus.ready);
  });

  test('later syncs only recount days of modified assets', () async {
    source.add('a', monday);
    await indexer.sync();
    final int pagesAfterFirstScan = source.pageCalls;

    source.add('b', tuesday, modified: DateTime.now().add(const Duration(minutes: 1)));
    await indexer.sync();

    expect(source.pageCalls, pagesAfterFirstScan);
    expect(repository.entryFor(_day(tuesday))!.totalCount, 1);
    expect(repository.meta.libraryCount, 2);
  });

  test('falls back to a full scan when an asset disappeared', () async {
    source
      ..add('a', monday)
      ..add('b', tuesday);
    await indexer.sync();
    final int pagesAfterFirstScan = source.pageCalls;

    source.assets.removeWhere((a) => a.$1.id == 'b');
    await indexer.sync();

    expect(source.pageCalls, greaterThan(pagesAfterFirstScan));
    expect(repository.entryFor(_day(tuesday)), isNull);
  });

  test('without access nothing is indexed', () async {
    source
      ..access = false
      ..add('a', monday);

    await indexer.sync();

    expect(repository.days, isEmpty);
    expect(indexer.currentProgress.status, GalleryIndexStatus.noAccess);
  });

  test('a day is known empty only after a complete scan and before the scan day', () async {
    expect(indexer.isKnownEmpty(_day(monday)), false);
    source.add('a', tuesday);
    await indexer.sync();

    expect(indexer.isKnownEmpty(_day(monday)), true);
    expect(indexer.isKnownEmpty(_day(tuesday)), false);
    expect(indexer.isKnownEmpty(DateUtils.getTodayIndex()), false);
  });

  test('a live day result updates that day and the library count', () async {
    source.add('a', monday);
    await indexer.sync();

    await indexer.refreshDay(_day(monday), [
      GalleryAssetInfo(id: 'a', createDate: monday, isVideo: false),
      GalleryAssetInfo(id: 'b', createDate: monday, isVideo: true),
    ]);
    expect(repository.entryFor(_day(monday))!.videoCount, 1);
    expect(repository.meta.libraryCount, 2);

    await indexer.refreshDay(_day(monday), const []);
    expect(repository.entryFor(_day(monday)), isNull);
    expect(repository.meta.libraryCount, 0);
  });
}
