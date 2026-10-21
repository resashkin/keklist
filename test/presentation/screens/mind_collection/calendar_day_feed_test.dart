import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/repositories/media_index/media_index_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/media_index/gallery_indexer.dart';
import 'package:keklist/domain/services/media_index/gallery_source.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';
import 'package:keklist/presentation/screens/mind_collection/calendar_day_feed.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';

final class _Repository implements MediaIndexRepository {
  final Map<int, MediaDayIndex> days;

  _Repository(this.days);

  @override
  Future<void> get ready => Future.value();

  @override
  MediaIndexMeta get meta => MediaIndexMeta.empty;

  @override
  MediaDayIndex? entryFor(int dayIndex) => days[dayIndex];

  @override
  Iterable<MediaDayIndex> get entries => days.values;

  @override
  void replaceAll({required Iterable<MediaDayIndex> entries, required MediaIndexMeta meta}) {}

  @override
  void putDays({required Iterable<MediaDayIndex> entries, required Iterable<int> emptyDayIndexes}) {}

  @override
  void updateMeta(MediaIndexMeta meta) {}
}

final class _Source implements GallerySource {
  @override
  bool get isSupported => true;

  @override
  Future<bool> hasAccess() async => true;

  @override
  Future<int> count() async => 0;

  @override
  Future<List<GalleryAssetInfo>> page({required int page, required int size}) async => const [];

  @override
  Future<List<GalleryAssetInfo>> modifiedSince(DateTime date) async => const [];

  @override
  Future<List<GalleryAssetInfo>> assetsOfDay(int dayIndex) async => const [];
}

Mind _mind(String id, int dayIndex, DateTime created, {String? rootId}) => Mind(
  id: id,
  note: id,
  dayIndex: dayIndex,
  creationDate: created,
  sortIndex: 0,
  rootId: rootId,
);

void main() {
  final DateTime morning = DateTime(2026, 3, 2, 9);
  late GalleryIndexer indexer;

  setUp(() {
    indexer = GalleryIndexer(
      repository: _Repository({
        10: MediaDayIndex(
          dayIndex: 10,
          photoCount: 1,
          videoCount: 0,
          assets: [GalleryAssetInfo(id: 'photo', createDate: morning.add(const Duration(hours: 1)), isVideo: false)],
        ),
        12: MediaDayIndex(
          dayIndex: 12,
          photoCount: 1,
          videoCount: 0,
          assets: [GalleryAssetInfo(id: 'only-media', createDate: morning, isVideo: false)],
        ),
      }),
      source: _Source(),
    );
  });

  final List<Mind> minds = [
    _mind('late', 10, morning.add(const Duration(hours: 2))),
    _mind('early', 10, morning),
    _mind('reflection', 10, morning, rootId: 'early'),
    _mind('other day', 11, morning),
  ];

  test('a day merges root minds and indexed media in time order', () {
    final CalendarDayFeed feed = CalendarDayFeed(minds: minds, indexer: indexer, includesMedia: true);

    expect(feed.itemsOf(10).map((item) => item.id), ['mind_early', 'asset_photo', 'mind_late']);
    expect((feed.itemsOf(10).first as DayFeedMind).reflectionCount, 1);
  });

  test('media stays out when it is turned off', () {
    final CalendarDayFeed feed = CalendarDayFeed(minds: minds, indexer: indexer, includesMedia: false);

    expect(feed.itemsOf(10).map((item) => item.id), ['mind_early', 'mind_late']);
    expect(feed.itemsOf(12), isEmpty);
  });

}
