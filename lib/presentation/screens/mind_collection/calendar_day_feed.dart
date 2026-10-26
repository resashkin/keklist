import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/media_index/gallery_indexer.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';
import 'package:keklist/domain/services/media_index/photo_library_gallery_source.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';

/// Feed items of every calendar day: root minds plus, when enabled, library media from the gallery index,
/// in the order and grouping the calendar tweaks picked.
final class CalendarDayFeed {
  final Map<int, List<DayFeedMind>> _mindsByDay;
  final GalleryIndexer? _indexer;
  final bool includesMedia;
  final FeedSortOrder sortOrder;
  final FeedGrouping grouping;
  final Set<String> hiddenMediaIds;
  final Map<int, List<DayFeedItem>> _itemsByDay = {};

  CalendarDayFeed._(
    this._mindsByDay,
    this._indexer,
    this.includesMedia,
    this.sortOrder,
    this.grouping,
    this.hiddenMediaIds,
  );

  factory CalendarDayFeed({
    required Iterable<Mind> minds,
    required GalleryIndexer? indexer,
    required bool includesMedia,
    FeedSortOrder sortOrder = FeedSortOrder.time,
    FeedGrouping grouping = FeedGrouping.none,
    Set<String> hiddenMediaIds = const {},
  }) {
    final Map<String, MindReflections> reflections = MindReflections.countAll(minds);
    final Map<int, List<DayFeedMind>> mindsByDay = {};
    for (final Mind mind in minds.where((mind) => mind.rootId == null)) {
      mindsByDay
          .putIfAbsent(mind.dayIndex, () => [])
          .add(DayFeedMind(mind: mind, reflections: reflections[mind.id] ?? const MindReflections()));
    }
    return CalendarDayFeed._(mindsByDay, indexer, includesMedia, sortOrder, grouping, hiddenMediaIds);
  }

  List<DayFeedSection> sectionsOf(int dayIndex) =>
      DayFeedLayout.arrange(itemsOf(dayIndex), sortOrder: sortOrder, grouping: grouping);

  List<DayFeedItem> itemsOf(int dayIndex) => _itemsByDay.putIfAbsent(dayIndex, () {
    final List<GalleryAssetInfo> assets = includesMedia ? _indexer?.entryFor(dayIndex)?.assets ?? const [] : const [];
    final List<DayFeedItem> merged = DayFeedLayout.merge(
      minds: _mindsByDay[dayIndex] ?? const [],
      media: [
        for (final GalleryAssetInfo asset in assets)
          if (!hiddenMediaIds.contains(DayFeedAsset.idOf(asset.id)))
            DayFeedAsset(PhotoLibraryGallerySource.entityOf(asset)),
      ],
    );
    return DayFeedLayout.arrangedItems(merged, sortOrder: sortOrder, grouping: grouping);
  });
}
