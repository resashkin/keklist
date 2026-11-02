import 'dart:io';

import 'package:keklist/domain/services/media_index/gallery_indexer.dart';
import 'package:keklist/domain/services/media_index/photo_library_gallery_source.dart';
import 'package:keklist/native/android/media_folder_channel.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart' as kek_date;
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/folder_media_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:photo_manager/photo_manager.dart';

final class DayMediaLoader {
  static const Set<String> _mediaExtensions = {
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif', 'mp4', 'mov', 'avi', 'mkv', 'm4v', //
  };

  static Future<bool> hasPhotoAccess({required bool requestIfNeeded}) async {
    final PermissionState permission = requestIfNeeded
        ? await PhotoManager.requestPermissionExtend()
        : await PhotoManager.getPermissionState(requestOption: const PermissionRequestOption());
    return permission.hasAccess;
  }

  /// Skips the library query for days the index knows are empty, and feeds every
  /// live result back into it.
  static Future<List<DayFeedAsset>> loadPhotoAssets(int dayIndex, {GalleryIndexer? indexer}) async {
    if (indexer?.isKnownEmpty(dayIndex) ?? false) return const [];
    final AssetPathEntity? path = await PhotoLibraryGallerySource.allPath(
      PhotoLibraryGallerySource.filter(createTimeCond: PhotoLibraryGallerySource.dayCond(dayIndex)),
    );
    final List<AssetEntity> assets = await PhotoLibraryGallerySource.allAssets(path);
    await indexer?.refreshDay(dayIndex, assets.map(PhotoLibraryGallerySource.infoOf));
    return assets.map(DayFeedAsset.new).toList();
  }

  static Future<List<DayFeedFolderMedia>> loadFolderMedia(
    int dayIndex,
    String folderPath, {
    required bool recursive,
  }) async {
    final (DateTime startOfDay, DateTime endOfDay) = _dayBounds(dayIndex);
    if (Platform.isAndroid) return _loadSafMedia(folderPath, startOfDay, endOfDay, recursive: recursive);
    return _loadFileMedia(folderPath, startOfDay, endOfDay, recursive: recursive);
  }

  static List<DayFeedFolderMedia> _loadFileMedia(
    String folderPath,
    DateTime startOfDay,
    DateTime endOfDay, {
    required bool recursive,
  }) {
    final Directory directory = Directory(folderPath);
    if (!directory.existsSync()) return [];
    return directory
        .listSync(recursive: recursive)
        .whereType<File>()
        .where((file) => _mediaExtensions.contains(file.path.split('.').last.toLowerCase()))
        .map((file) => DayFeedFolderMedia(item: FolderFileItem(file), timestamp: file.statSync().modified))
        .where((media) => _isWithin(media.timestamp, startOfDay, endOfDay))
        .toList();
  }

  static Future<List<DayFeedFolderMedia>> _loadSafMedia(
    String treeUri,
    DateTime startOfDay,
    DateTime endOfDay, {
    required bool recursive,
  }) async {
    try {
      final List<SafFileInfo> files = await MediaFolderChannel.listFiles(treeUri, recursive: recursive);
      return files
          .where((file) => !file.isDirectory && _isMediaMimeType(file.mimeType))
          .where((file) => file.lastModified != null && _isWithin(file.lastModified!, startOfDay, endOfDay))
          .map(
            (file) => DayFeedFolderMedia(
              item: FolderSafItem(uri: Uri.parse(file.uri), mimeType: file.mimeType, lastModified: file.lastModified),
              timestamp: file.lastModified!,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static (DateTime, DateTime) _dayBounds(int dayIndex) {
    final DateTime date = kek_date.DateUtils.getDateFromDayIndex(dayIndex);
    final DateTime startOfDay = DateTime(date.year, date.month, date.day);
    return (startOfDay, startOfDay.add(const Duration(days: 1)));
  }

  static bool _isWithin(DateTime moment, DateTime start, DateTime end) =>
      !moment.isBefore(start) && moment.isBefore(end);

  static bool _isMediaMimeType(String? mimeType) =>
      mimeType != null && (mimeType.startsWith('image/') || mimeType.startsWith('video/'));
}
