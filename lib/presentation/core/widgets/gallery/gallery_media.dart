import 'package:keklist/domain/services/phone_web/gallery_wire.dart';
import 'package:keklist/domain/services/phone_web/phone_web_mode.dart';
import 'package:keklist/presentation/core/widgets/gallery/cached_asset_thumbnail_provider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:video_player/video_player.dart';

/// Library media from Photos on the phone, or from the phone over the network in the web version.
abstract final class GalleryMedia {
  static ImageProvider thumbnail(AssetEntity asset) =>
      kIsPhoneWeb ? NetworkImage(_url(GalleryWire.thumbnailPath(asset.id))) : CachedAssetThumbnailProvider(asset);

  static ImageProvider original(AssetEntity asset) => kIsPhoneWeb
      ? NetworkImage(_url(GalleryWire.originalPath(asset.id)))
      : AssetEntityImageProvider(asset, isOriginal: true);

  static Future<VideoPlayerController?> videoController(AssetEntity asset) async {
    if (kIsPhoneWeb) return VideoPlayerController.networkUrl(Uri.parse(_url(GalleryWire.originalPath(asset.id))));
    return switch (await asset.file) {
      final file? => VideoPlayerController.file(file),
      null => null,
    };
  }

  static String _url(String path) => Uri.base.resolve(path).toString();
}
