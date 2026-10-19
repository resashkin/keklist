# Day Feed ("All" mode) Implementation

## Overview

The day screen (`MindDayCollectionScreen`) has two modes:

- **Sources**: the original stack of cards (minds card, photo/folder media tile, weather tile). The Sources button now sits below the last tile instead of in the AppBar.
- **All**: one gallery-like grid where the day's minds and media are mixed in time order. Tapping any tile opens an Instagram-style stories viewer.

The AppBar icon (`grid_view` / `view_agenda_outlined`) switches modes. The choice is persisted.

## Implementation Details

### 1. Domain Layer

- `SettingsObject` gets Hive fields 21–25: `isDayFeedModeEnabled`, `dayFeedColumnCount` (default 4), `dayFeedMindCellSpan` (default 1), `isDayFeedMindTextVisible` (default true), `isDayFeedAudioBadgeVisible` (default true).
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
- In All mode a floating `KekFloatingButton` ("+ Write", same as the minds list) opens the mind creator; on other days it sits next to "To now". The grid ends with bottom padding so the button never covers the last row.
- While media loads, `2 × columnCount` shimmer cells are appended.
- `DayFeedSettingsBottomSheet` (AppBar `tune` icon, All mode only): column count (3/4/5, whole grid), mind tile size (square / wide), mind text, audio badge.
- `DayStoriesScreen`: progress bars, auto-advance, tap left/right third for previous/next, middle tap or swipe up on a mind opens `MindInfoScreen`, hold to pause, swipe down to close, closes after the last item.
- `FolderMediaThumbnail` was extracted from `FolderGalleryScreen` so the grid can reuse it.

## How It Works

1. Toggling the AppBar icon sends `SettingsUpdateDayFeed(isEnabled: ...)`.
2. When the mode turns on, the screen calls `DayFeedCubit.loadMedia`; minds are already set.
3. Media source, independent of the Sources toggles:
   - iOS: the photo library. Permission is only *checked*; the "Allow" banner button requests it and opens system settings if it stays denied.
   - Android: the chosen media folder (SAF). Without one, the banner opens the folder picker.
4. Items are merged and sorted by timestamp ascending: `Mind.creationDate`, `AssetEntity.createDateTime`, or the file's modification time. A mind written later for a past day therefore sorts by when it was typed.
5. Reflections (`rootId != null`) are not tiles; the root tile shows their count.

### Story durations

| Item | Duration |
|---|---|
| Photo | 5 s |
| Video | full length |
| Mind | 3 s + 60 ms per character, capped at 12 s |

Audio notes are not played in stories; a mic icon is shown.

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
- `lib/presentation/screens/mind_day_collection/widgets/day_feed/` (new): `day_feed_item.dart`, `day_feed_layout.dart`, `day_media_loader.dart`, `day_feed_cubit.dart`, `day_feed_tiles.dart`, `day_feed_sliver.dart`, `day_feed_settings_bottom_sheet.dart`, `day_stories_screen.dart`
- `lib/presentation/screens/date_gallery/folder_media_thumbnail.dart` (extracted), `folder_gallery_screen.dart`

**Localization**: 15 `dayFeed*` keys in all 12 ARB files.

**Dependencies**: `flutter_volume_controller`.

## Testing

- Unit: `test/presentation/screens/mind_day_collection/day_feed_layout_test.dart` covers mind filtering and reflection counts, time ordering, row packing and story durations.
- Manual:
  1. Open a day with minds and photos and switch to All. Minds appear at once and photos fill in.
  2. Change the tile settings and check the grid updates live.
  3. Deny photo access, then check the banner appears and its button works.
  4. Overscroll to the previous or next day in All mode.
  5. Open stories and check tap/hold/swipe, video mute and volume buttons, and that a mind swipe up opens MindInfo and resumes the story on return.

## Edge Cases & Considerations

- When the debug "Sensitive Content" item is enabled and content is hidden, mind tiles and mind stories show only the emoji; media is unaffected.
- The volume listener sets the iOS audio session category to `playback` while the stories viewer is open.
- Weather is never shown in All mode.
- Media loading reads all of a day's asset metadata up front (as the existing galleries do); thumbnails are built lazily per visible row.
