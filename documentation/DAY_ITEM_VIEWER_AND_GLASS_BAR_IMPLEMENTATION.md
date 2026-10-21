# Day Item Viewer, Stories Details & Glass Bar Implementation

## Overview
Tapping a tile (day screen, calendar, insights) opens a swipeable viewer of that day's items instead of
timed stories. ▶ buttons (day screen header, calendar day pill, "Week #N") play stories for the period.
Every tab uses a transparent top bar with frosted "glass" bubbles, title centered.

## Implementation Details
### Viewer — `day_feed/day_item_viewer_screen.dart`
- `DayItemViewerScreen.show(context, items, initialIndex, onOpenMind)` — `PageView` over `DayFeedItem`s.
- Header: full date + time, "open" for minds, close. Page dots, or "n / N" above 12 items.
- Pages: mind details (with audio player), round video, video (looping, tap to pause), photo
  (`InteractiveViewer`, cached thumbnail then original), SAF photo via `MediaFolderChannel.getDocumentContent`.
- Dismiss by dragging down or overscrolling at the top.

### Mind details — `day_feed/mind_story_details.dart`
- `storyColorsOf(context)`: black background on dark theme, white on light; used by stories and viewer.
- `MindStoryDetails`: emotion chips ("😄 Root › Child" via `EmotionsList.ancestorsOf`), text, audio, reflections.
- `MindAudioPlayerView`: just_audio play/pause, seek slider, elapsed / total.

### Calendar headers — `mind_collection/local_widgets/calendar_day_header.dart`
- `CalendarDayPill`: centered stadium pill — date, "No activity" caption on empty days, chevron, and a ▶ segment
  when the day has items. Today uses the primary color.
- `CalendarWeekHeader`: centered "Week #N" with ▶ for the whole week (shown only if the week has items).

### Glass bar — `core/widgets/glass_app_bar.dart`
- `GlassAppBar(title, onTitleTap, onTitleLongPress, actions, centerTitle)`; `GlassBubble` = blur + translucent
  surface + hairline border + soft shadow. A gradient fades content under the status bar.
- Screens set `extendBodyBehindAppBar: true` and pad lists by `MediaQuery.paddingOf(context).top`.
- Calendar jumps use an alignment fraction so the target day lands below the bar.

### Pinch to change columns — `core/widgets/pinch_columns_detector.dart`
- Raw `Listener` (outside the gesture arena) tracking two pointers; each 1.3× ratio step changes columns by one,
  clamped 2–7, with a selection haptic. Used in the day screen and the calendar.

## Edge Cases & Considerations
- Text tiles compute `maxLines` from tile height and end with "…".
- Hidden tabs in `IndexedStack` are detected with `Visibility.of(context)` (Flutter 3.47 keeps `TickerMode` on),
  see `SHAKE_TO_TWEAK_IMPLEMENTATION.md`.
