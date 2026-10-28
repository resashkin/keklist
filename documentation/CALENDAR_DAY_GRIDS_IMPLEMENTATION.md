# Calendar Day Grids Implementation

## Overview
The calendar tab showed each day as a row of emotion emojis, plus a month grid on long-press. Now every day shows the same tile grid as the day screen: minds and the photos/videos of that day from the gallery index, with no row limit. Shaking the calendar (or long-pressing its title) opens its own settings.

## Implementation Details

### 1. Domain Layer
- Gallery index stores every asset of a day with enough data for a tile (`GALLERY_INDEX_IMPLEMENTATION.md`).
- `CalendarSettings` on `KeklistSettings`: `columnCount` (Hive field 31, default 4), `isMindTextVisible` (32), `isMediaVisible` (33). Week titles keep using `shouldShowTitles`.

### 2. BLoC Layer
- `SettingsUpdateCalendar` → `updateSettings(copyWith(calendar:))`. Week titles go through `SettingsUpdateShouldShowTitlesMode`.

### 3. UI Layer
- `CalendarDayFeed` (`mind_collection/calendar_day_feed.dart`): root minds grouped by day once, merged with indexed media per day on demand and cached.
- `_MindCollectionBody`: the endless `ScrollablePositionedList` of every day (position == day index), as before — week title, the date (tap → day screen), then `DayFeedGrid`. Empty days are just the date.
- `DayFeedGrid` (`day_feed/day_feed_grid.dart`): a box version of the day grid; `DayFeedItemTile` is shared with the day screen sliver.
- Tile tap → `DayStoriesScreen` of that day, starting at the tile.
- `CalendarSettingsBottomSheet`: columns 3/4/5, show text, show photos and videos, week titles. `ShakeScreenIds.calendar`.
- Removed: the month grid (`mind_month_collection_widget.dart`), `MindRowWidget`/`DayEmotionsText`, `DayEmotionSummary`, the commented demo body, the `scrollview_observer` dependency.

## How It Works
1. Minds or settings change → `CalendarDayFeed` is rebuilt; days build their items lazily as they scroll in.
2. The gallery indexer reports `ready` → the feed is rebuilt so new media appears.

## Updated Files
- Domain: `media_day_index.dart`, `media_day_index_builder.dart`, `photo_library_gallery_source.dart`, `media_index_repository.dart`, `media_index_hive_repository.dart`, `media_day_index_object.dart` (+ `.g.dart`), `gallery_indexer.dart`; settings repository/object (+ `.g.dart`).
- DI/bootstrap: `containers.dart`, `main.dart`.
- UI: `mind_collection_screen.dart`, `mind_collection_body.dart`, `mind_collection_app_bar.dart`, `calendar_day_feed.dart`, `calendar_settings_bottom_sheet.dart`, `day_feed_grid.dart`, `day_feed_tiles.dart`, `day_feed_sliver.dart`, `day_feed_layout.dart`, `shake_to_tweak_mixin.dart`.
- L10n: `calendarSettings`, `calendarShowMedia`, `calendarWeekTitles` in all 12 ARB files.

## Testing
- `test/presentation/screens/mind_collection/calendar_day_feed_test.dart`: merge order, media off, non-empty days.
- `test/domain/repositories/media_index/media_day_index_object_test.dart`: asset string round trip.
- `settings_bloc_test.dart`: `SettingsUpdateCalendar` keeps other fields.
- Manual (iOS 26 simulator with photos): open Calendar, check minds and photos per day; tap a photo → stories; long-press the title → change columns, turn media off.

## Edge Cases & Considerations
- Media comes only from the gallery index (iOS). On Android, or before the first index build, the calendar shows minds only.
- A photo taken after the last sync appears after the next `sync()` (launch or resume).
- Days with many photos are tall; that is intended (no row limit).

## Headers, Viewer & Pinch
Days are headed by a centered `CalendarDayPill` and weeks by `CalendarWeekHeader`, both with ▶ to play stories.
Tiles open `DayItemViewerScreen`; pinching changes the column count (2–7). See
`DAY_ITEM_VIEWER_AND_GLASS_BAR_IMPLEMENTATION.md`.

## Today & Current Week
- Today is wrapped in `_TodayFrame` (2pt primary border, light tint); the today pill keeps its fill.
- `_CurrentWeekBubble`: a glass "↑/↓ To current week" bubble above the tab bar, shown while no day of the current week
  is on screen; it scrolls to today. The old "To now" button of the day screen is gone.
