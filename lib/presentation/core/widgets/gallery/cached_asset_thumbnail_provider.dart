import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:keklist/presentation/core/widgets/gallery/gallery_thumbnail_cache.dart';
import 'package:photo_manager/photo_manager.dart';

/// Decodes an asset's [GalleryThumbnailCache] thumbnail; equal for the same asset version.
@immutable
final class CachedAssetThumbnailProvider extends ImageProvider<CachedAssetThumbnailProvider> {
  final AssetEntity asset;

  const CachedAssetThumbnailProvider(this.asset);

  @override
  Future<CachedAssetThumbnailProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<CachedAssetThumbnailProvider>(this);

  @override
  ImageStreamCompleter loadImage(CachedAssetThumbnailProvider key, ImageDecoderCallback decode) =>
      MultiFrameImageStreamCompleter(codec: _loadCodec(decode), scale: 1.0, debugLabel: 'thumbnail ${asset.id}');

  Future<ui.Codec> _loadCodec(ImageDecoderCallback decode) async {
    final Uint8List? bytes = await GalleryThumbnailCache.load(asset);
    if (bytes == null) throw StateError('No thumbnail for asset ${asset.id}');
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is CachedAssetThumbnailProvider &&
      other.asset.id == asset.id &&
      other.asset.modifiedDateTime == asset.modifiedDateTime;

  @override
  int get hashCode => Object.hash(asset.id, asset.modifiedDateTime);
}
