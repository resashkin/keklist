import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/media_index/gallery_indexer.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';
import 'package:keklist/domain/services/media_index/photo_library_gallery_source.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_media_loader.dart';
import 'package:keklist/domain/services/phone_web/phone_web_mode.dart';

enum DayFeedMediaIssue { photoAccessDenied, folderNotChosen }

final class DayFeedState {
  final List<DayFeedItem> items;
  final bool isMediaLoading;
  final DayFeedMediaIssue? mediaIssue;

  const DayFeedState({required this.items, required this.isMediaLoading, this.mediaIssue});
}

final class DayFeedCubit extends Cubit<DayFeedState> {
  final GalleryIndexer? _galleryIndexer;
  List<DayFeedItem> _minds = const [];
  List<DayFeedItem> _media = const [];
  bool _isMediaLoading = true;
  DayFeedMediaIssue? _mediaIssue;
  int _mediaRequestId = 0;

  DayFeedCubit({GalleryIndexer? galleryIndexer})
    : _galleryIndexer = galleryIndexer,
      super(const DayFeedState(items: [], isMediaLoading: true));

  void setMinds({required int dayIndex, required Iterable<Mind> allMinds}) {
    _minds = DayFeedLayout.mindItemsForDay(dayIndex: dayIndex, allMinds: allMinds);
    _emit();
  }

  Future<void> loadMedia({
    required int dayIndex,
    required String? folderPath,
    required bool isFolderRecursive,
    bool requestPhotoAccess = false,
  }) async {
    final int requestId = ++_mediaRequestId;
    _media = const [];
    _mediaIssue = null;
    _isMediaLoading = true;
    _emit();

    final (List<DayFeedItem> media, DayFeedMediaIssue? issue) = kIsPhoneWeb
        ? await _loadPhoneMedia(dayIndex)
        : Platform.isAndroid
        ? await _loadFolderMedia(dayIndex, folderPath, isFolderRecursive)
        : await _loadPhotoMedia(dayIndex, requestPhotoAccess, requestId);

    if (requestId != _mediaRequestId || isClosed) return;
    _media = media;
    _mediaIssue = issue;
    _isMediaLoading = false;
    _emit();
  }

  // The phone answers with its photo library on iOS and its media folder on Android.
  Future<(List<DayFeedItem>, DayFeedMediaIssue?)> _loadPhoneMedia(int dayIndex) async {
    final List<GalleryAssetInfo> assets =
        await _galleryIndexer?.assetsOfDay(dayIndex).catchError((_) => <GalleryAssetInfo>[]) ?? const [];
    return (
      [for (final GalleryAssetInfo asset in assets) DayFeedAsset(PhotoLibraryGallerySource.entityOf(asset))],
      null,
    );
  }

  Future<(List<DayFeedItem>, DayFeedMediaIssue?)> _loadPhotoMedia(
    int dayIndex,
    bool requestAccess,
    int requestId,
  ) async {
    final bool hasAccess = await DayMediaLoader.hasPhotoAccess(requestIfNeeded: requestAccess);
    if (!hasAccess) return (const <DayFeedItem>[], DayFeedMediaIssue.photoAccessDenied);
    if (requestAccess) _galleryIndexer?.sync();
    _showIndexedMedia(dayIndex, requestId);
    return (await DayMediaLoader.loadPhotoAssets(dayIndex, indexer: _galleryIndexer), null);
  }

  /// The index already knows the day's assets: they take their final places at once, and the live
  /// query that follows only corrects what changed since the last scan.
  void _showIndexedMedia(int dayIndex, int requestId) {
    final MediaDayIndex? entry = _galleryIndexer?.entryFor(dayIndex);
    if (entry == null || requestId != _mediaRequestId) return;
    _media = [
      for (final GalleryAssetInfo asset in entry.assets) DayFeedAsset(PhotoLibraryGallerySource.entityOf(asset)),
    ];
    _isMediaLoading = false;
    _emit();
  }

  Future<(List<DayFeedItem>, DayFeedMediaIssue?)> _loadFolderMedia(
    int dayIndex,
    String? folderPath,
    bool recursive,
  ) async {
    if (folderPath == null) return (const <DayFeedItem>[], DayFeedMediaIssue.folderNotChosen);
    return (await DayMediaLoader.loadFolderMedia(dayIndex, folderPath, recursive: recursive), null);
  }

  void _emit() {
    if (isClosed) return;
    emit(
      DayFeedState(
        items: DayFeedLayout.merge(minds: _minds, media: _media),
        isMediaLoading: _isMediaLoading,
        mediaIssue: _mediaIssue,
      ),
    );
  }
}
