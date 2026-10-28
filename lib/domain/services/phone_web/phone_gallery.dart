import 'dart:async';

import 'package:keklist/domain/repositories/media_index/media_index_repository.dart';
import 'package:keklist/domain/services/media_index/gallery_source.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';
import 'package:keklist/domain/services/phone_web/gallery_wire.dart';
import 'package:keklist/domain/services/phone_web/phone_api.dart';

/// The phone's gallery index, read-only: the phone scans its library and the web version only mirrors the result.
final class PhoneMediaIndexRepository implements MediaIndexRepository {
  PhoneMediaIndexRepository({required PhoneApi api}) : _api = api {
    _ready = reload();
  }

  final PhoneApi _api;
  late Future<void> _ready;
  MediaIndexMeta _meta = MediaIndexMeta.empty;
  Map<int, MediaDayIndex> _days = const {};

  Future<void> reload() async {
    try {
      final Object? json = await _api.get('/api/gallery');
      if (json is! Map<String, dynamic>) return;
      final (MediaIndexMeta meta, List<MediaDayIndex> days) = GalleryWire.indexFromJson(json);
      _meta = meta;
      _days = {for (final MediaDayIndex day in days) day.dayIndex: day};
    } on Object {
      // Without the index the web version just shows no library media.
    }
  }

  @override
  Future<void> get ready => _ready;

  @override
  MediaIndexMeta get meta => _meta;

  @override
  MediaDayIndex? entryFor(int dayIndex) => _days[dayIndex];

  @override
  Iterable<MediaDayIndex> get entries => _days.values;

  @override
  FutureOr<void> replaceAll({required Iterable<MediaDayIndex> entries, required MediaIndexMeta meta}) {}

  @override
  FutureOr<void> putDays({required Iterable<MediaDayIndex> entries, required Iterable<int> emptyDayIndexes}) {}

  @override
  FutureOr<void> updateMeta(MediaIndexMeta meta) {}
}

/// Asks the phone instead of a photo library; scanning is the phone's job, so there is never anything new to page.
final class PhoneGallerySource implements GallerySource {
  const PhoneGallerySource({required PhoneApi api, required MediaIndexRepository index}) : _api = api, _index = index;

  final PhoneApi _api;
  final MediaIndexRepository _index;

  @override
  bool get isSupported => true;

  @override
  Future<bool> hasAccess() async => true;

  @override
  Future<int> count() async => _index.meta.libraryCount;

  @override
  Future<List<GalleryAssetInfo>> page({required int page, required int size}) async => const [];

  @override
  Future<List<GalleryAssetInfo>> modifiedSince(DateTime date) async => const [];

  @override
  Future<List<GalleryAssetInfo>> assetsOfDay(int dayIndex) async {
    final Object? json = await _api.get('/api/gallery/day?day=$dayIndex');
    return [
      for (final List<dynamic> asset in (json as List<dynamic>).cast<List<dynamic>>()) GalleryWire.assetFromJson(asset),
    ];
  }
}
