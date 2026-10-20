import 'package:keklist/domain/services/media_index/media_day_index.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';

/// Folds assets into per-day [MediaDayIndex] entries; previews keep the newest ids.
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
    final List<GalleryAssetInfo> newestFirst = unique.values.toList()
      ..sort((a, b) => b.createDate.compareTo(a.createDate));
    final int videoCount = newestFirst.where((asset) => asset.isVideo).length;
    return MediaDayIndex(
      dayIndex: dayIndex,
      photoCount: newestFirst.length - videoCount,
      videoCount: videoCount,
      previewIds: newestFirst.take(MediaDayIndex.maxPreviewIds).map((asset) => asset.id).toList(),
    );
  }
}
