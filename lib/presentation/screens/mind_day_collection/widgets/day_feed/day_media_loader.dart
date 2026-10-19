import 'dart:io';

import 'package:keklist/native/android/media_folder_channel.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart' as kek_date;
import 'package:keklist/presentation/screens/date_gallery/folder_media_item.dart';
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

  static Future<List<DayFeedAsset>> loadPhotoAssets(int dayIndex) async {
    final (DateTime startOfDay, DateTime endOfDay) = _dayBounds(dayIndex);
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(sizeConstraint: SizeConstraint(ignoreSize: true)),
        videoOption: const FilterOption(sizeConstraint: SizeConstraint(ignoreSize: true)),
        createTimeCond: DateTimeCond(min: startOfDay, max: endOfDay),
      ),
    );

    // The same asset shows up in several albums (Recents, Favorites, ...).
    final Map<String, AssetEntity> assetsById = {};
    for (final AssetPathEntity path in paths) {
      final int count = await path.assetCountAsync;
      if (count == 0) continue;
      for (final AssetEntity asset in await path.getAssetListRange(start: 0, end: count)) {
        assetsById[asset.id] = asset;
      }
    }

    return assetsById.values
        .where((asset) => _isWithin(asset.createDateTime, startOfDay, endOfDay))
        .map(DayFeedAsset.new)
        .toList();
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
