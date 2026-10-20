import 'package:equatable/equatable.dart';

/// Photo-library summary of one day: counts plus the ids of its newest assets.
final class MediaDayIndex with EquatableMixin {
  static const int maxPreviewIds = 8;

  final int dayIndex;
  final int photoCount;
  final int videoCount;
  final List<String> previewIds;

  const MediaDayIndex({
    required this.dayIndex,
    required this.photoCount,
    required this.videoCount,
    required this.previewIds,
  });

  int get totalCount => photoCount + videoCount;

  @override
  List<Object?> get props => [dayIndex, photoCount, videoCount, previewIds];
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

/// One library asset as the indexer sees it.
final class GalleryAssetInfo {
  final String id;
  final DateTime createDate;
  final bool isVideo;

  const GalleryAssetInfo({required this.id, required this.createDate, required this.isVideo});
}
