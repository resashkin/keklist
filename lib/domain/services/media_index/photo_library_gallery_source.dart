import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:keklist/domain/services/media_index/gallery_source.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';
import 'package:photo_manager/photo_manager.dart';

/// Reads the "All" album only, so an asset in several albums is seen once.
final class PhotoLibraryGallerySource implements GallerySource {
  const PhotoLibraryGallerySource();

  static FilterOptionGroup filter({DateTimeCond? createTimeCond, DateTimeCond? updateTimeCond}) => FilterOptionGroup(
    imageOption: const FilterOption(sizeConstraint: SizeConstraint(ignoreSize: true)),
    videoOption: const FilterOption(sizeConstraint: SizeConstraint(ignoreSize: true)),
    createTimeCond: createTimeCond,
    updateTimeCond: updateTimeCond,
    orders: const [OrderOption(type: OrderOptionType.createDate, asc: false)],
  );

  static DateTimeCond dayCond(int dayIndex) {
    final DateTime date = DateUtils.getDateFromDayIndex(dayIndex);
    final DateTime start = DateTime(date.year, date.month, date.day);
    return DateTimeCond(min: start, max: start.add(const Duration(days: 1)));
  }

  static Future<AssetPathEntity?> allPath(FilterOptionGroup filterOption) async {
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.common,
      filterOption: filterOption,
    );
    return paths.firstOrNull;
  }

  static Future<List<AssetEntity>> allAssets(AssetPathEntity? path) async {
    if (path == null) return const [];
    final int count = await path.assetCountAsync;
    return count == 0 ? const [] : path.getAssetListRange(start: 0, end: count);
  }

  static GalleryAssetInfo infoOf(AssetEntity asset) => GalleryAssetInfo(
    id: asset.id,
    createDate: asset.createDateTime,
    modifiedDate: asset.modifiedDateTime,
    isVideo: asset.type == AssetType.video,
    width: asset.width,
    height: asset.height,
    durationSeconds: asset.duration,
  );

  /// Rebuilds a usable entity from the index, so thumbnails and stories work without a library query.
  static AssetEntity entityOf(GalleryAssetInfo info) => AssetEntity(
    id: info.id,
    typeInt: (info.isVideo ? AssetType.video : AssetType.image).index,
    width: info.width,
    height: info.height,
    duration: info.durationSeconds,
    createDateSecond: info.createDate.millisecondsSinceEpoch ~/ 1000,
    modifiedDateSecond: info.modifiedDate.millisecondsSinceEpoch ~/ 1000,
  );

  /// Fires while the app runs whenever the library changes, e.g. after a screenshot; call once access is granted.
  static Stream<void> libraryChanges() {
    late final StreamController<void> controller;
    void onChange(MethodCall _) => controller.add(null);
    controller = StreamController<void>.broadcast(
      onListen: () {
        PhotoManager.addChangeCallback(onChange);
        PhotoManager.startChangeNotify();
      },
      onCancel: () {
        PhotoManager.removeChangeCallback(onChange);
        PhotoManager.stopChangeNotify();
      },
    );
    return controller.stream;
  }

  @override
  bool get isSupported => !kIsWeb && Platform.isIOS;

  @override
  Future<bool> hasAccess() async =>
      (await PhotoManager.getPermissionState(requestOption: const PermissionRequestOption())).hasAccess;

  @override
  Future<int> count() async => await (await allPath(filter()))?.assetCountAsync ?? 0;

  @override
  Future<List<GalleryAssetInfo>> page({required int page, required int size}) async {
    final AssetPathEntity? path = await allPath(filter());
    if (path == null) return const [];
    return (await path.getAssetListPaged(page: page, size: size)).map(infoOf).toList();
  }

  @override
  Future<List<GalleryAssetInfo>> modifiedSince(DateTime date) async {
    final DateTimeCond updated = DateTimeCond(min: date, max: DateTime.now().add(const Duration(days: 1)));
    return (await allAssets(await allPath(filter(updateTimeCond: updated)))).map(infoOf).toList();
  }

  @override
  Future<List<GalleryAssetInfo>> assetsOfDay(int dayIndex) async =>
      (await allAssets(await allPath(filter(createTimeCond: dayCond(dayIndex))))).map(infoOf).toList();
}
