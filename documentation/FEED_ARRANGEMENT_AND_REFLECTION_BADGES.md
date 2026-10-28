# Feed Arrangement, Day Frames and Reflection Badges Implementation

## Overview
The day screen and the calendar can order and group a day's tiles. Calendar days sit in their own frames, the day
header counts emotions, and mind tiles show their comments, round videos and audio notes as icons. The web version
is reached by IP only; the Bonjour/mDNS name is gone.

## Implementation Details

### 1. Domain Layer
- `settings_repository.dart`: `FeedSortOrder {time, mindsFirst, mediaFirst}` and `FeedGrouping {none, type,
  timeOfDay}`, kept separately in `DayFeedSettings` and `CalendarSettings` (both have `copyWith`).
- `settings_object.dart`: Hive fields 44–45 (day) and 46–47 (calendar), stored as enum indexes.

### 2. BLoC Layer
- `SettingsUpdateDayFeedArrangement({sortOrder, grouping})` for the day screen; the calendar keeps using
  `SettingsUpdateCalendar` with `copyWith`.

### 3. Layout
- `DayFeedLayout.arrange(items, sortOrder:, grouping:)` returns `DayFeedSection`s (`kind` is null without grouping).
  Within each kind items stay in time order. Type grouping puts the gallery first only for "Media first". Time of
  day: night < 5, morning < 12, afternoon < 17, evening.
- `DayFeedLayout.arrangedItems` flattens the sections. Stories always open with this list, so their order and the
  tapped index match the screen. `arrange` is idempotent, so `CalendarDayFeed.itemsOf` caches arranged items and
  `sectionsOf` splits them again for the headers.
- `MindReflections` (`day_feed_item.dart`) counts the reflections of a root mind by kind: video, audio, or a
  written comment. `DayFeedMind.reflectionCount` is its total.

### 4. UI Layer
- `FeedArrangementTweaks` (Order and Groups) sits in both shake sheets. Every segmented tweak (`TweakChoice`,
  `ColumnCountRow`, story date lines) now uses `GlassSegmentedSwitcher` from Insights, which plays its own haptics.
- `DayFeedSectionHeader`: an icon and caption over each group, in `DayFeedSliver` and `DayFeedGrid`.
- Calendar: `_DayFrame` wraps every day, faint for most days and accented for today; the pill and ▶ have no
  outline. `_DayCounters` adds ☺ with the number of emotion marks of the day's minds.
- The day screen's title is 14/11 pt with tight line heights, so the weekday is no longer clipped.
- `_ReflectionsBadge`: a dark pill at the bottom left of a mind tile, with icons for comments, videos and audio.
  Text tiles keep room for it. It is hidden on tiles smaller than 48 pt.

### 5. Web version by IP only
- Deleted: `name_announcer.dart`, `bonjour_announcer.dart`, `mdns_responder.dart`, `ios/Runner/BonjourPlugin.swift`
  and its registration, and `NSBonjourServices`.
- `WebServerRunning` has no `name`/`nameProblem`; the Host check accepts IPs and `localhost` only.

## Testing
- `day_feed_layout_test.dart`: reflection kinds, every sort order and grouping, and idempotence.
- `day_feed_mind_tile_test.dart`: the badge's icons and counts, and when it is hidden.
- Manual: shake on the day screen or calendar, switch Order and Groups, open a tile, and check the story order.

## Edge Cases & Considerations
- While media loads with grouping on, the skeletons get their own section at the end.
- Switching grouping rebuilds the section grids, so tiles fly only inside a section.
