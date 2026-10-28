import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/media_index/gallery_indexer.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';
import 'package:keklist/domain/services/media_index/photo_library_gallery_source.dart';
import 'package:keklist/domain/services/phone_web/gallery_wire.dart';
import 'package:keklist/domain/services/web_server/serve_file.dart';
import 'package:keklist/native/android/media_folder_channel.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_media_loader.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/folder_media_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

/// The phone's gallery for the web version: the iOS photo library, or the media folder picked on Android.
/// Photos go out as JPEG since browsers can't show HEIC; videos as files with byte ranges.
final class GalleryRoutes {
  GalleryRoutes({required GalleryIndexer indexer, required SettingsRepository settings})
    : _indexer = indexer,
      _settings = settings;

  final GalleryIndexer _indexer;
  final SettingsRepository _settings;

  /// Only folder files listed to a browser can be fetched by it.
  final Map<String, FolderSafItem> _folderItems = {};

  static const int _thumbnailPixels = 400;
  static const int _originalPixels = 2048;
  static const String _folderPrefix = 'saf:';

  Stream<void> get changes =>
      _indexer.progress.where((progress) => progress.status == GalleryIndexStatus.ready).map((_) {});

  Object indexJson() => GalleryWire.indexToJson(_indexer.meta, _indexer.entries);

  Future<Object> dayJson(int dayIndex) async {
    final List<GalleryAssetInfo> assets = defaultTargetPlatform == TargetPlatform.android
        ? await _folderAssets(dayIndex)
        : await _libraryAssets(dayIndex);
    final Set<String> hidden = _settings.value.hiddenMediaIds;
    return [
      for (final GalleryAssetInfo asset in assets)
        if (!hidden.contains(_feedIdOf(asset.id))) GalleryWire.assetToJson(asset),
    ];
  }

  Future<List<GalleryAssetInfo>> _libraryAssets(int dayIndex) async {
    const PhotoLibraryGallerySource source = PhotoLibraryGallerySource();
    if (!source.isSupported || !await source.hasAccess()) return const [];
    return source.assetsOfDay(dayIndex);
  }

  Future<List<GalleryAssetInfo>> _folderAssets(int dayIndex) async {
    final KeklistSettings settings = _settings.value;
    final String? folder = settings.mediaFolderPath;
    if (folder == null) return const [];
    final List<DayFeedFolderMedia> media = await DayMediaLoader.loadFolderMedia(
      dayIndex,
      folder,
      recursive: settings.isMediaFolderRecursive,
    );
    return [
      for (final DayFeedFolderMedia item in media)
        if (item.item case final FolderSafItem saf)
          GalleryAssetInfo(id: _register(saf), createDate: item.timestamp, isVideo: saf.isVideo),
    ];
  }

  /// The id the app's feed knows this asset by, which is what hiding stores.
  String _feedIdOf(String id) => id.startsWith(_folderPrefix)
      ? 'saf_${_folderItems[id]?.uri}'
      : DayFeedAsset.idOf(id);

  String _register(FolderSafItem item) {
    final String id = '$_folderPrefix${base64Url.encode(utf8.encode(item.uri.toString()))}';
    _folderItems[id] = item;
    return id;
  }

  Future<void> thumbnail(HttpRequest request) async {
    final String id = request.uri.queryParameters['id'] ?? '';
    final Uint8List? bytes;
    if (id.startsWith(_folderPrefix)) {
      final FolderSafItem? item = _folderItems[id];
      final String? uri = item?.uri.toString();
      bytes = uri == null
          ? null
          : item!.isVideo
          ? await MediaFolderChannel.getVideoThumbnail(uri)
          : await MediaFolderChannel.getDocumentThumbnail(
              uri,
              _thumbnailPixels.toDouble(),
              _thumbnailPixels.toDouble(),
            );
    } else {
      bytes = await (await AssetEntity.fromId(id))?.thumbnailDataWithSize(
        const ThumbnailSize.square(_thumbnailPixels),
        format: ThumbnailFormat.jpeg,
        quality: 85,
      );
    }
    if (bytes == null) return _notFound(request.response);
    request.response.headers
      ..contentType = ContentType('image', 'jpeg')
      ..set(HttpHeaders.cacheControlHeader, 'private, max-age=86400');
    request.response.add(bytes);
  }

  Future<void> original(HttpRequest request) async {
    final String id = request.uri.queryParameters['id'] ?? '';
    final (File, String)? original = id.startsWith(_folderPrefix)
        ? await _folderOriginal(id)
        : await _libraryOriginal(id);
    if (original == null) return _notFound(request.response);
    final (File file, String contentType) = original;
    await serveFile(request, file, contentType: contentType, cacheControl: 'private, max-age=86400');
  }

  Future<(File, String)?> _libraryOriginal(String id) async {
    final AssetEntity? asset = await AssetEntity.fromId(id);
    if (asset == null) return null;
    if (asset.type == AssetType.video) {
      final File? file = await asset.file;
      if (file == null) return null;
      return (file, file.path.toLowerCase().endsWith('.mov') ? 'video/quicktime' : 'video/mp4');
    }
    final File cached = await _cacheFile('$id@${asset.modifiedDateSecond}', 'jpg');
    if (!await cached.exists()) {
      final Uint8List? bytes = await asset.thumbnailDataWithSize(
        const ThumbnailSize.square(_originalPixels),
        format: ThumbnailFormat.jpeg,
        quality: 90,
      );
      if (bytes == null) return null;
      await cached.writeAsBytes(bytes, flush: true);
    }
    return (cached, 'image/jpeg');
  }

  Future<(File, String)?> _folderOriginal(String id) async {
    final FolderSafItem? item = _folderItems[id];
    if (item == null) return null;
    final File cached = await _cacheFile('$id@${item.lastModified?.millisecondsSinceEpoch}', 'bin');
    if (!await cached.exists()) {
      final Uint8List? bytes = await MediaFolderChannel.getDocumentContent(item.uri.toString());
      if (bytes == null) return null;
      await cached.writeAsBytes(bytes, flush: true);
    }
    return (cached, item.mimeType ?? 'application/octet-stream');
  }

  static Future<File> _cacheFile(String key, String extension) async {
    final Directory directory = Directory('${(await getTemporaryDirectory()).path}/web_gallery');
    await directory.create(recursive: true);
    return File('${directory.path}/${sha1.convert(utf8.encode(key))}.$extension');
  }

  static void _notFound(HttpResponse response) {
    response
      ..statusCode = HttpStatus.notFound
      ..headers.contentType = ContentType.text
      ..write('Not found');
  }
}
