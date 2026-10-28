# Day Item Viewer, Stories Details & Glass Bar Implementation

## Overview
Tapping a tile (day screen, calendar, insights, search, digest) opens a swipeable viewer of that day's items instead
of timed stories. The viewer replaced the full-screen `MindInfoScreen`, which was deleted: minds are edited in place. ▶ buttons (day screen header, calendar day pill, "Week #N") play stories for the period.
Every tab uses a transparent top bar with frosted "glass" bubbles, title centered.

## Implementation Details
### Viewer — `day_feed/day_item_viewer_screen.dart`
- `DayItemViewerScreen.show(context, items, initialIndex, onOpenMind)` — `PageView` over `DayFeedItem`s.
- Header: ⋯ (minds: edit, translate in debug, remove media, delete), a centered `StoryDateHeader`, ✕.
  Page dots, or "n / N" above 12 items. `DayItemViewerScreen.showMind` opens a single mind.
- Minds are read live from `MindBloc` by id, so edits show at once.
- Tap the text → inline `TextField` with Cancel / Save (`MindEdit`, audio/video pieces kept).
- Tap the emotion pill under the content → `EmotionMarkingSheet` (`MindSetEmotions`); a mind without emotions shows a pale "☺︎ ＋" pill.
- `MindCreatorBottomBar` at the bottom adds text, audio or video comments; long-press a comment → Edit / Remove media /
  Delete sheet; Edit loads it into the bar.
- Pulling a page down past its top (80pt) closes the viewer; the page fades (up to 85%) and slides with the pull.
- The emotion texture fills the whole screen; the header and comment bar float over it.
- Pages: mind details (audio as `MindAudioCircle`), round video (inside `SoundSpectrumRing`), video (looping, tap to pause), photo
  (`InteractiveViewer`, cached thumbnail then original), SAF photo via `MediaFolderChannel.getDocumentContent`.
- Dismiss by dragging down or overscrolling at the top.

### Mind details — `day_feed/mind_story_details.dart`
- `StoryDateHeader`: "21 October · Wednesday · 14:05" on 1, 2 (default) or 3 lines (`StoryDateLayout`, Hive field 36);
  the first line is larger. `storyDateLines` builds the lines and is unit-tested.
- Edit hooks (`onTapText`, `textEditor`, `onEditEmotions`, `onLongPressReflection`) are null in stories, which stay
  read-only; tapping the middle of a mind story (or swiping up) opens the viewer at that item.
- `storyColorsOf(context)`: black background on dark theme, white on light; used by stories and viewer.
- `MindStoryDetails`: content first (media, then text), then `MindEmotionsPill` (overlapping emojis), then reflections.
- `MindEmotionChips` ("😄 Root › Child") stays for reflections, read-only.
- `MindAudioCircle` (`day_feed/mind_audio_circle.dart`): a circle filled with the first emotion's color, ▶/⏸ in the
  center, a progress ring and a horizontal seek bar under it. In stories it only shows the story's own player.

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

### Sound-reactive emotion texture — `core/widgets/sound/`
- `SoundEnvelope`: loudness 0…1 at 30 levels per second, extracted once per file with `just_waveform` (audio, and the
  sound track of round videos) and cached next to it as `<file>.waveform`; normalized to the file's 95th percentile.
- `SoundPlayback` (+ `SoundPlaybackScope`): players register what is playing; `level` is 0 when paused or muted.
- `AnimatedEmotionTexture`: "😄 Joy" labels tiled at -15° behind story/viewer minds, painted by a `CustomPainter`
  driven by a ticker. Minds without emotions get a plain background.
- Animations (`StoryTextureAnimation`, Hive field 35 — field 34 held the removed "hide empty days" flag): Off, Pulse,
  Wave, Equalizer, Drift, Glow. Picked in `StoryTextureTweakSheet`, opened by shaking stories or the viewer.
  `textureCellMotion` holds the per-cell math and is unit-tested.
- `SoundSpectrumRing`: 56 rays around audio and round-video circles, length from the loudness envelope plus per-ray
  variation (`spectrumRayLength`, unit-tested; not a real FFT). Loud sound reaches past the circle.
- The tweak sheet also holds date lines, a spectrum switch (field 37) and one sensitivity slider 0.5–3× (field 38)
  that scales both the texture and the rays; all four live in `StorySettings`.

### Calendar day pill
- Full date, counters (✎ minds · 📷 photos · 🎥 videos, zeros hidden), chevron; min 200 wide, 48 high; ▶ is a separate
  circle. Empty days show the shared `DayEmptyState` ("No minds for this day"), same as the day screen.

### Tile text
- `fitTileText` (`day_feed/tile_text_fitting.dart`) steps the font down until every word fits on a line and the text
  fits the tile; a word too wide even at the minimum size is cut with "…" instead of breaking mid-word.

## Edge Cases & Considerations
- Shake is ignored by screens whose route is not current (`ModalRoute.isCurrent`), so a see-through stories/viewer
  route does not also trigger the screen below.
- Simulator "Device → Shake" does not reach the accelerometer stream, so the tweak sheet needs a real device.
- Text tiles compute `maxLines` from tile height and end with "…".
- Hidden tabs in `IndexedStack` are detected with `Visibility.of(context)` (Flutter 3.47 keeps `TickerMode` on),
  see `SHAKE_TO_TWEAK_IMPLEMENTATION.md`.
