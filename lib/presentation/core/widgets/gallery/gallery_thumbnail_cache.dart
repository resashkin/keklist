import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

/// Small JPEG thumbnails of library assets kept on disk, so a day's grid opens
/// without asking Photos to render them again.
abstract final class GalleryThumbnailCache {
  static const int sidePixels = 240;
  static const int quality = 70;
  static const String _folderName = 'gallery_thumbnails';

  static Future<Directory>? _directory;

  /// Bytes on disk; null until [refreshSize] has measured the folder once.
  static final ValueNotifier<int?> size = ValueNotifier<int?>(null);

  static Future<Directory> directory() => _directory ??= () async {
    final Directory base = await getApplicationSupportDirectory();
    return Directory('${base.path}/$_folderName').create(recursive: true);
  }();

  // An edited photo gets a new modification date and therefore a new file.
  static String fileNameOf(String assetId, DateTime modifiedDate) =>
      '${assetId.replaceAll(RegExp('[^A-Za-z0-9]'), '_')}_${modifiedDate.millisecondsSinceEpoch ~/ 1000}.jpg';

  static Future<Uint8List?> load(AssetEntity asset) async {
    final File file = File('${(await directory()).path}/${fileNameOf(asset.id, asset.modifiedDateTime)}');
    if (await file.exists()) return file.readAsBytes();
    final Uint8List? bytes = await asset.thumbnailDataWithSize(
      const ThumbnailSize.square(sidePixels),
      quality: quality,
    );
    if (bytes != null) {
      await file.writeAsBytes(bytes, flush: false);
      final int? current = size.value;
      if (current != null) size.value = current + bytes.length;
    }
    return bytes;
  }

  static Future<void> refreshSize() async {
    final Directory folder = await directory();
    int total = 0;
    await for (final FileSystemEntity entity in folder.list()) {
      if (entity is File) total += await entity.length();
    }
    size.value = total;
  }

  static Future<void> clear() async {
    final Directory folder = await directory();
    if (await folder.exists()) await folder.delete(recursive: true);
    _directory = null;
    size.value = 0;
  }
}
