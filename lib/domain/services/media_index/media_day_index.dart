import 'package:equatable/equatable.dart';

/// Photo-library summary of one day: counts plus every asset, oldest first.
final class MediaDayIndex with EquatableMixin {
  final int dayIndex;
  final int photoCount;
  final int videoCount;
  final List<GalleryAssetInfo> Function() _decodeAssets;

  MediaDayIndex({
    required this.dayIndex,
    required this.photoCount,
    required this.videoCount,
    required List<GalleryAssetInfo> assets,
  }) : _decodeAssets = (() => assets);

  /// Stored days decode their assets only when asked, so counting days stays cheap.
  MediaDayIndex.lazy({
    required this.dayIndex,
    required this.photoCount,
    required this.videoCount,
    required List<GalleryAssetInfo> Function() decodeAssets,
  }) : _decodeAssets = decodeAssets;

  late final List<GalleryAssetInfo> assets = _decodeAssets();

  int get totalCount => photoCount + videoCount;

  @override
  List<Object?> get props => [dayIndex, photoCount, videoCount, assets];
}

/// State of the whole index; [isComplete] is false until the first full scan finishes.
final class MediaIndexMeta with EquatableMixin {
  final bool isComplete;
  final int libraryCount;
  final DateTime? lastScanDate;

  const MediaIndexMeta({required this.isComplete, required this.libraryCount, required this.lastScanDate});

  static const MediaIndexMeta empty = MediaIndexMeta(isComplete: false, libraryCount: 0, lastScanDate: null);

  @override
  List<Object?> get props => [isComplete, libraryCount, lastScanDate];
}

/// One library asset as the indexer sees it; enough to show its tile without asking Photos.
final class GalleryAssetInfo with EquatableMixin {
  final String id;
  final DateTime createDate;
  final DateTime modifiedDate;
  final bool isVideo;
  final int width;
  final int height;
  final int durationSeconds;

  GalleryAssetInfo({
    required this.id,
    required this.createDate,
    required this.isVideo,
    DateTime? modifiedDate,
    this.width = 0,
    this.height = 0,
    this.durationSeconds = 0,
  }) : modifiedDate = modifiedDate ?? createDate;

  @override
  List<Object?> get props => [id, createDate, modifiedDate, isVideo, width, height, durationSeconds];
}
