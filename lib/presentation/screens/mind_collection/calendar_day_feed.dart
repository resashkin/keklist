import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/media_index/gallery_indexer.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';
import 'package:keklist/domain/services/media_index/photo_library_gallery_source.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';

/// Feed items of every calendar day: root minds plus, when enabled, library media from the gallery index.
final class CalendarDayFeed {
  final Map<int, List<DayFeedMind>> _mindsByDay;
  final GalleryIndexer? _indexer;
  final bool includesMedia;
  final Map<int, List<DayFeedItem>> _itemsByDay = {};

  CalendarDayFeed._(this._mindsByDay, this._indexer, this.includesMedia);

  factory CalendarDayFeed({
    required Iterable<Mind> minds,
    required GalleryIndexer? indexer,
    required bool includesMedia,
  }) {
    final Map<String, int> reflectionCounts = {};
    for (final Mind mind in minds) {
      final String? rootId = mind.rootId;
      if (rootId != null) reflectionCounts[rootId] = (reflectionCounts[rootId] ?? 0) + 1;
    }
    final Map<int, List<DayFeedMind>> mindsByDay = {};
    for (final Mind mind in minds.where((mind) => mind.rootId == null)) {
      mindsByDay
          .putIfAbsent(mind.dayIndex, () => [])
          .add(DayFeedMind(mind: mind, reflectionCount: reflectionCounts[mind.id] ?? 0));
    }
    return CalendarDayFeed._(mindsByDay, indexer, includesMedia);
  }

  List<DayFeedItem> itemsOf(int dayIndex) => _itemsByDay.putIfAbsent(dayIndex, () {
    final List<GalleryAssetInfo> assets = includesMedia ? _indexer?.entryFor(dayIndex)?.assets ?? const [] : const [];
    return DayFeedLayout.merge(
      minds: _mindsByDay[dayIndex] ?? const [],
      media: [for (final GalleryAssetInfo asset in assets) DayFeedAsset(PhotoLibraryGallerySource.entityOf(asset))],
    );
  });
}
