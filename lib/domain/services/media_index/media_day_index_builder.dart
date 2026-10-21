import 'package:keklist/domain/services/media_index/media_day_index.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';

/// Folds assets into per-day [MediaDayIndex] entries; duplicates by id count once.
final class MediaDayIndexBuilder {
  final Map<int, List<GalleryAssetInfo>> _assetsByDay = {};

  void addAll(Iterable<GalleryAssetInfo> assets) {
    for (final GalleryAssetInfo asset in assets) {
      _assetsByDay.putIfAbsent(DateUtils.getDayIndex(from: asset.createDate), () => []).add(asset);
    }
  }

  Set<int> get dayIndexes => _assetsByDay.keys.toSet();

  List<MediaDayIndex> build() => [for (final int dayIndex in _assetsByDay.keys) buildDay(dayIndex)!];

  MediaDayIndex? buildDay(int dayIndex) {
    final List<GalleryAssetInfo>? assets = _assetsByDay[dayIndex];
    if (assets == null || assets.isEmpty) return null;
    final Map<String, GalleryAssetInfo> unique = {for (final GalleryAssetInfo asset in assets) asset.id: asset};
    final List<GalleryAssetInfo> oldestFirst = unique.values.toList()
      ..sort((a, b) => a.createDate.compareTo(b.createDate));
    final int videoCount = oldestFirst.where((asset) => asset.isVideo).length;
    return MediaDayIndex(
      dayIndex: dayIndex,
      photoCount: oldestFirst.length - videoCount,
      videoCount: videoCount,
      assets: oldestFirst,
    );
  }
}
