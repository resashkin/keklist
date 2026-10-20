# Day Feed Implementation

## Overview

The day screen (`MindDayCollectionScreen`) is one gallery-like grid where the day's minds and media are mixed in time order. Tapping any tile opens an Instagram-style stories viewer. Weather, when enabled, is drawn faintly behind the grid as an easter egg.

There used to be a second "Sources" mode (a stack of minds, photo, folder and weather cards with full-screen galleries) and an AppBar toggle between the two. Both were removed; the grid is the only view.

## Implementation Details

### 1. Domain Layer

- `SettingsObject` Hive fields 22–24: `dayFeedColumnCount` (default 4), `dayFeedMindCellSpan` (default 1), `isDayFeedMindTextVisible` (default true). Field 25 (`isDayFeedAudioBadgeVisible`) is retired: audio minds always show their icon.
- Retired fields, never to be reused: 11 (`isPhotoVideoSourceEnabled`), 15 (`isMediaFolderSourceEnabled`), 21 (`isDayFeedModeEnabled`), 25 (`isDayFeedAudioBadgeVisible`). Media always comes from the photo library (iOS) or the chosen folder (Android).
- `KeklistSettings.dayFeed` exposes them as a `DayFeedSettings` value object.
- `SettingsRepository.updateDayFeedSettings(...)` updates any subset of them.
- Every place that rebuilds `KeklistSettings` field by field (`MigrationRunner`, `SettingsBloc._enableDebugMenu`, `LazyOnboardingBloc`) passes `dayFeed` through, so those flows do not reset the layout.

### 2. BLoC Layer

- `SettingsUpdateDayFeed` event → `SettingsBloc._updateDayFeed`.
- `DayFeedCubit` (`widgets/day_feed/day_feed_cubit.dart`) owns the grid state:
  - `setMinds` recomputes mind items instantly (on every `MindBloc` update and day switch).
  - `loadMedia` loads media asynchronously; stale results from a previous day are dropped via a request counter.
  - `DayFeedState.mediaIssue` is `photoAccessDenied` (iOS) or `folderNotChosen` (Android).

### 3. UI Layer

- `DayFeedSliver` renders the banner, the grid and the empty state as slivers inside a `CustomScrollView` that shares the screen's `ScrollController`, so overscroll-to-switch-day keeps working.
- Rows are packed by `DayFeedLayout.packIntoRows` and built lazily with `SliverList.builder`. A wide mind that does not fit at the end of a row starts a new row; order is never changed to fill gaps.
- A floating `KekFloatingButton` ("+ Create") opens the mind creator; on other days it sits next to "To now". The grid ends with bottom padding so the button never covers the last row.
- While media loads, `2 × columnCount` shimmer cells are appended.
- `DayFeedSettingsBottomSheet` (shake or long-press the title): column count (3/4/5, whole grid), mind tile size (square / wide), mind text, the PRO weather toggle with its location sheet, and on Android the media folder sheet (folder and subfolders).
- `DayWeatherBackdrop`: a large, very faint icon, temperature and place name pinned to the bottom-right corner in a `Stack` under the scroll view. It ignores touches; tiles cover it on busy days.
- `DayStoriesScreen`: progress bars, auto-advance, tap left/right third for previous/next, middle tap or swipe up on a mind opens `MindInfoScreen`, hold to pause, swipe down to close, closes after the last item.
- `FolderMediaThumbnail` and `FolderMediaItem` live in `widgets/day_feed/`.

## How It Works

1. On the first settings state, and whenever the Android folder changes, the screen calls `DayFeedCubit.loadMedia`; minds are already set.
2. Media source:
   - iOS: the photo library ("All" album), skipped for days the gallery index knows are empty (see `GALLERY_INDEX_IMPLEMENTATION.md`). Permission is only *checked*; the "Allow" banner button requests it and opens system settings if it stays denied.
   - Android: the chosen media folder (SAF). Without one, the banner opens the folder picker.
3. Items are merged and sorted by timestamp ascending: `Mind.creationDate`, `AssetEntity.createDateTime`, or the file's modification time. A mind written later for a past day therefore sorts by when it was typed.
4. Reflections (`rootId != null`) are not tiles; the root tile shows their count.

### Story durations

| Item | Duration |
|---|---|
| Photo | 5 s |
| Video | full length |
| Mind | 3 s + 60 ms per character, capped at 12 s |

Voice and round-video minds last as long as their recording (see `MEDIA_MINDS_IMPLEMENTATION.md`).

### Video sound

Videos start muted. They are unmuted by the speaker icon or by pressing a hardware volume button (`flutter_volume_controller` listener). The mute state lives in a static field, so it is remembered until the app restarts. iOS exposes no API for the ring/silent switch, so it is not consulted.

## Updated Files

**Domain**
- `lib/domain/repositories/settings/object/settings_object.dart` (+ `.g.dart`)
- `lib/domain/repositories/settings/settings_repository.dart`
- `lib/domain/repositories/settings/settings_hive_repository.dart`
- `lib/domain/migrations/migration_runner.dart`

**BLoC**
- `lib/presentation/blocs/settings_bloc/settings_bloc.dart`, `settings_event.dart`
- `lib/presentation/blocs/lazy_onboarding_bloc/lazy_onboarding_bloc.dart`

**UI**
- `lib/presentation/screens/mind_day_collection/mind_day_collection_screen.dart`
- `lib/presentation/screens/mind_day_collection/widgets/day_feed/`: `day_feed_item.dart`, `day_feed_layout.dart`, `day_media_loader.dart`, `day_feed_cubit.dart`, `day_feed_tiles.dart`, `day_feed_sliver.dart`, `day_feed_settings_bottom_sheet.dart`, `day_stories_screen.dart`, `day_weather_backdrop.dart`, `folder_media_item.dart`, `folder_media_thumbnail.dart`
- Removed with Sources mode: `day_minds_card/`, `day_media_tile/`, `sources_bottom_sheet/`, `photo_video_settings_bottom_sheet/`, `weather_tile/`, `screens/date_gallery/` (galleries, viewers, bloc), `screens/device_gallery/`, `screens/weather_detail/`, and the `photo_view` dependency

**Localization**: 15 `dayFeed*` keys in all 12 ARB files.

**Dependencies**: `flutter_volume_controller`.

## Testing

- Unit: `test/presentation/screens/mind_day_collection/day_feed_layout_test.dart` covers mind filtering and reflection counts, time ordering, row packing and story durations. `day_weather_backdrop_test.dart` covers the backdrop's text, icon choice and that it ignores touches.
- Manual:
  1. Open a day with minds and photos. Minds appear at once and photos fill in.
  2. Change the tile settings and check the grid updates live.
  3. Deny photo access, then check the banner appears and its button works.
  4. Overscroll to the previous or next day.
  5. Open stories and check tap/hold/swipe, video mute and volume buttons, and that a mind swipe up opens MindInfo and resumes the story on return.
  6. Turn on weather in the shake sheet and check the faint backdrop in the bottom-right corner.

## Edge Cases & Considerations

- Mind tiles and stories show the emojis of the mind's emotions; a text-less mind without emotions shows a faint notes icon.
- The volume listener sets the iOS audio session category to `playback` while the stories viewer is open.
- Weather has no detail screen any more; the backdrop is decorative only.
- Media loading reads all of a day's asset metadata up front; thumbnails are built lazily per visible row and cached on disk by `GalleryThumbnailCache`.

## Mind tiles
- All minds share one card tile (`DayFeedMindTile`).
- Text minds: emotion emojis on top, then the text as `AutoSizeText` (14 → 7 pt), wrapping to fill the tile.
- Round-video minds: the video circle (70% of the tile) with no text. Audio minds: a waveform icon of the same size, no circle and no text. Both show their emotion emojis top-left and the duration bottom-right.
- There are no reflection-count badges on tiles; stories still show the count.

