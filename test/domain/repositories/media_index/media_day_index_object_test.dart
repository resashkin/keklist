import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/repositories/media_index/object/media_day_index_object.dart';
import 'package:keklist/domain/services/media_index/media_day_index.dart';

void main() {
  test('day assets survive the compact string round trip', () {
    final List<GalleryAssetInfo> assets = [
      GalleryAssetInfo(id: 'A1B2-C3/L0/001', createDate: DateTime(2026, 3, 2, 9), isVideo: false, width: 4032, height: 3024),
      GalleryAssetInfo(
        id: 'D4E5-F6/L0/001',
        createDate: DateTime(2026, 3, 2, 18),
        modifiedDate: DateTime(2026, 3, 5),
        isVideo: true,
        width: 1080,
        height: 1920,
        durationSeconds: 42,
      ),
    ];
    final MediaDayIndex entry = MediaDayIndex(dayIndex: 7, photoCount: 1, videoCount: 1, assets: assets);

    final MediaDayIndex restored = MediaDayIndexObject.fromEntry(entry).toEntry();

    expect(restored, entry);
    expect(restored.assets, assets);
  });

  test('a day without assets restores an empty list', () {
    final MediaDayIndex entry = MediaDayIndex(dayIndex: 1, photoCount: 0, videoCount: 0, assets: const []);
    expect(MediaDayIndexObject.fromEntry(entry).toEntry().assets, isEmpty);
  });
}
