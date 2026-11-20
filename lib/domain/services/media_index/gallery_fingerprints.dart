import 'dart:io';

import 'package:keklist/domain/repositories/mind/mind_repository.dart';
import 'package:keklist/domain/services/entities/mind.dart';
import 'package:keklist/domain/services/entities/photo_fingerprint.dart';
import 'package:photo_manager/photo_manager.dart';

/// Fingerprints of gallery photos and videos, and the move of comments off the old device-local roots.
abstract final class GalleryFingerprints {
  /// The photo library knows when a photo was taken and its size.
  static PhotoFingerprint ofAsset(AssetEntity asset) =>
      PhotoFingerprint.of(asset.createDateTime, width: asset.width, height: asset.height);

  /// An Android folder file by its own time only. Its comments only need to survive an export to another Android
  /// phone with the same files; photos are never shared between an iPhone and an Android phone.
  static PhotoFingerprint ofFolderFile(DateTime timestamp) => PhotoFingerprint.of(timestamp);

  /// Comments and emotion tags made before fingerprints hang on this phone's ids (`asset_…`, `file_…`); they move to
  /// the photo's fingerprint so an export carries them to other phones. Ids that no longer resolve stay as they are.
  static Future<void> migrateLegacyRoots(MindRepository minds) async {
    final Map<String, List<Mind>> byLegacyRoot = {};
    for (final Mind mind in minds.values) {
      final String? root = mind.rootId;
      if (root != null && _isLegacyGalleryRoot(root)) byLegacyRoot.putIfAbsent(root, () => []).add(mind);
    }
    if (byLegacyRoot.isEmpty) return;
    final Set<String> fingerprintRoots = {
      for (final Mind mind in minds.values)
        if (mind.rootId case final String root when PhotoFingerprint.isKey(root)) root,
    };
    final List<Mind> moved = [];
    for (final MapEntry<String, List<Mind>> entry in byLegacyRoot.entries) {
      final PhotoFingerprint? fingerprint = await _ofLegacyRoot(entry.key);
      if (fingerprint == null) continue;
      final String root = fingerprint.rootAmong(fingerprintRoots);
      fingerprintRoots.add(root);
      moved.addAll(entry.value.map((mind) => mind.copyWith(rootId: root)));
    }
    if (moved.isNotEmpty) await minds.updateMinds(minds: moved);
  }

  static bool _isLegacyGalleryRoot(String root) =>
      root.startsWith('asset_') || root.startsWith('file_') || root.startsWith('saf_');

  static Future<PhotoFingerprint?> _ofLegacyRoot(String root) async {
    try {
      if (root.startsWith('asset_')) {
        final AssetEntity? asset = await AssetEntity.fromId(root.substring('asset_'.length));
        return asset == null ? null : ofAsset(asset);
      }
      if (root.startsWith('file_')) {
        final File file = File(root.substring('file_'.length));
        if (!await file.exists()) return null;
        return ofFolderFile(await file.lastModified());
      }
    } catch (_) {}
    // A SAF document's time can't be read back without its folder listing.
    return null;
  }
}
