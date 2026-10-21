# Gallery Index Implementation

## Overview
The day screen used to query every Photos album for the selected day and ask Photos to render thumbnails again each time. The gallery index keeps a per-day summary of the photo library in Hive and keeps small thumbnails on disk. Days with no media open without touching Photos, thumbnails show instantly on return visits, and the full-quality image loads only when a photo is opened.

Phase 2 of the main-emoji/analytics work. The index is also the data source for the media counters planned for the analytics redesign (phase 3).

## Implementation Details

### 1. Domain Layer
- `MediaDayIndex` (`lib/domain/services/media_index/media_day_index.dart`): `dayIndex`, `photoCount`, `videoCount`, `assets` (every asset of the day, oldest first). `MediaIndexMeta`: `isComplete`, `libraryCount`, `lastScanDate`.
- `GalleryAssetInfo` keeps what a tile needs: id, create/modify dates, video flag, size, duration. `PhotoLibraryGallerySource.entityOf` turns it back into an `AssetEntity`, so the calendar shows thumbnails and stories without querying Photos.
- `MediaDayIndexBuilder`: folds `GalleryAssetInfo` into per-day entries; duplicates by id are counted once.
- `MediaIndexRepository` / `MediaIndexHiveRepository`:
  - `media_day_index_box` (typed, `MediaDayIndexObject`, typeId 5), keyed by `dayIndex`;
  - `media_index_meta_box` (untyped) for the meta.
  - Both encrypted like the other boxes.
  - A day's assets are stored as one string (`assetRecords`, field 4; field 3 with preview ids is retired) and decoded only when that day is read. Thousands of small Hive objects made box opening slow.
  - The boxes open in the background (`ready`); until then the index reads as empty, so app start never waits for it.
  - `formatVersion` in the meta box: an index written in an older format counts as incomplete, so the next `sync()` rebuilds it.
- `GallerySource` abstracts the library; `PhotoLibraryGallerySource` reads only the "All" album with `photo_manager`, so an asset that is in several albums is seen once.
- `GalleryIndexer` (singleton in `MainContainer`, also provided via `RepositoryProvider`):
  - `sync()` — first time a full paged scan (500 per page); afterwards only the days of assets modified since the last scan are recounted.
  - After an incremental pass the expected library size (stored count ± recount deltas) is compared with the real count; any mismatch (deletions, missed changes) triggers a full scan.
  - `rebuild()` — forced full scan.
  - `refreshDay()` — the day screen's live query result is written back, so the index heals itself.
  - `isKnownEmpty(dayIndex)` — true only for a complete index, a day before the last scan day, and no entry.
  - `progress` stream of `GalleryIndexProgress` (`unsupported`, `noAccess`, `idle`, `indexing`, `ready`).

### 2. Presentation
- Startup (`_AppRootState`): `sync()` after the app is built and again on every resume (`AppLifecycleListener`). It never asks for Photos permission; when the day screen gets access, it calls `sync()` itself.
- `DayMediaLoader.loadPhotoAssets` skips known-empty days, queries the "All" album for the day otherwise, and calls `refreshDay`.
- `GalleryThumbnailCache`: 240 px JPEG (quality 70) per asset in `<app support>/gallery_thumbnails`, named by asset id and modification second, so edited photos get a fresh file.
- `CachedAssetThumbnailProvider`: an `ImageProvider` over the cache, equal per asset version, so Flutter's memory cache dedupes it too. Used by `DayFeedAssetTile`.
- Stories show the cached thumbnail immediately and fade the original in on top.
- Settings → "Gallery index" (`GalleryIndexTile`): status, a progress bar while indexing, the thumbnail cache size. While a scan runs the row moves into an "Active tasks" section at the very top (shown only then, not customizable); otherwise it lives under User data. Tap → confirm → clear thumbnails and rebuild. Hidden where the index is unsupported. The row can be hidden through the settings customize sheet like any other.

## How It Works
1. App starts → `sync()`. No access → status `noAccess`, nothing else happens.
2. Index incomplete → full scan, progress shown in Settings → `replaceAll` + meta `isComplete`.
3. Next start/resume → modified-since query → recount touched days → count check → done (or full scan).
4. Day screen opens a past day with no entry → no Photos query. Any other day → live query → `refreshDay`.

## Updated Files
- Domain: `lib/domain/services/media_index/*`, `lib/domain/repositories/media_index/*`, `lib/domain/hive_constants.dart`.
- DI/bootstrap: `lib/di/containers.dart`, `lib/main.dart`.
- Day feed: `day_media_loader.dart`, `day_feed_cubit.dart`, `day_feed_tiles.dart`, `day_stories_screen.dart`, `mind_day_collection_screen.dart`.
- Thumbnails: `lib/presentation/core/widgets/gallery/*`.
- Settings: `settings_screen.dart`, `settings_layout.dart`, `widgets/gallery_index_tile.dart`; 9 new ARB keys in all 12 files.

## Testing
- `test/domain/services/media_index/gallery_indexer_test.dart`: builder, full scan, incremental scan, deletion fallback, no access, known-empty rule, `refreshDay`.
- Manual (iOS simulator with photos): open Settings → watch the index finish; open a day with photos, leave and return — tiles appear without a flash; open a photo — the blurry thumbnail sharpens.

## Edge Cases & Considerations
- iOS only. On Android media comes from a user-picked folder (SAF), which is not indexed; the Settings row is hidden there.
- Only the "All"/Recents album is read. Hidden photos and shared-album items that are not in Recents are not shown (the old per-album loop could include them).
- An old-dated photo imported after the last scan stays hidden on its (known-empty) day until the next `sync()` (next launch or resume).
- The thumbnail folder grows with the photos you actually look at (~15 KB each); "Rebuild" clears it.
- An interrupted full scan leaves `isComplete == false`, so the next `sync()` starts over.
- Startup: the gallery index box is no longer part of "Opening database..."; the calendar and the day screen pick the index up when `sync()` finishes.
