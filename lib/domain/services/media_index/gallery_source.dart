import 'package:keklist/domain/services/media_index/media_day_index.dart';

/// Read-only view of the device photo library used by the indexer.
abstract interface class GallerySource {
  bool get isSupported;
  Future<bool> hasAccess();
  Future<int> count();
  Future<List<GalleryAssetInfo>> page({required int page, required int size});
  Future<List<GalleryAssetInfo>> modifiedSince(DateTime date);
  Future<List<GalleryAssetInfo>> assetsOfDay(int dayIndex);
}
