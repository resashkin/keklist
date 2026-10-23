# Insights Redesign Implementation

## Overview
The analytics tab was three loosely related widgets (an emoji pie chart, a top-emoji bar chart, a random mind). With the main emoji gone (`MAIN_EMOJI_REMOVAL_IMPLEMENTATION.md`), it is rebuilt around emotions, activity, memories and media: calm cards in the style of iOS Health, one period for the whole screen, and a layout the user can change by shaking the phone.

Phase 3 of the main-emoji work; media counts come from the gallery index (`GALLERY_INDEX_IMPLEMENTATION.md`).

## Implementation Details

### 1. Domain Layer (`lib/domain/services/insights/`)
- `InsightsPeriod` — Week / Month / Year / All time.
  - `current` runs from the period start (the week starts on the locale's first day) to today.
  - `previous` is the same elapsed span of the previous period: Oct 1–20 compares with Sep 1–20. All time has none.
  - `segments` are one level below: week → days, month → weeks (clipped to the month), year → months, all time → years.
  - `heatmapRange` is the whole week or calendar month (days still ahead included, drawn faded), or the last 52 weeks for Year / All time. Week and month draw a compact calendar of fixed 28pt cells with weekday letters.
  - `calendarDateOf` reads calendar fields from a UTC date, so results don't depend on the device time zone.
- `InsightsCalculator` (pure) → `InsightsReport`:
  - **Counters**: root minds, active days, words (reflections included), each with the delta.
  - **Brightest segment**: highest `minds + 2 × distinct emotions + media` (minds with audio/video plus library photos/videos).
  - **Emotion shares**: per top-level emotion. A mind counts fully in every top-level emotion it touches, and once per child one level down (the drill-down).
  - **Trend**: top-level counts per segment.
  - **Pairs**: tagged emotions that appear on the same mind, top 5.
  - **Rhythm**: the dominant top-level emotion per weekday and per part of the day (night < 6, morning < 12, afternoon < 18, evening), with mind ids for taps.
  - **Streak**: consecutive days with a root mind. It ends today, or yesterday while today is still empty, so a streak survives until today is over. Longest streak is over all time.
  - **Heatmap**: root minds per day. **Minds by hour**: 24 buckets.
  - **Back then** (`onThisDay`): `MemoryPoint` a week, a month, half a year, a year and two years ago; a date missing in a shorter month falls on its last day. Empty points are left out.
  - **Media**: library photos/videos in the period, minds with audio, minds with round video; `voiceMindIds` holds the newest 12 minds with a voice note or round video for the "Voice and round videos" strip (audio as a mic circle in the mind's emotion color).

### 2. Settings
- `InsightsSettings` on `KeklistSettings`: `widgetOrder` (Hive field 28), `hiddenWidgetIds` (29), `periodIndex` (30, default Month).
- Saved through `SettingsUpdateInsights` → `updateSettings(copyWith(insights:))`.

### 3. UI Layer (`lib/presentation/screens/insights/`)
- `InsightsWidgetId` — the 12 cards with category and default order. `ordered()` keeps the saved order, drops unknown ids and appends new cards.
- `InsightsCard` — rounded `surfaceContainerHigh` card with a small colored category header, an optional period label and a chevron when tappable. `InsightsEmptyHint` is the compact one-line empty state every card falls back to.
- Cards:
  - `insights_summary_cards.dart`: counters, brightest segment. Its label carries the year, and for a week the week number (`InsightsFormat.weekOfYear`: ISO 8601 for Monday weeks, otherwise week 1 holds January 1).
  - `insights_emotion_cards.dart`: distribution with drill-down, trend, pairs, rhythm.
  - `insights_activity_cards.dart`: streak, heatmap, time of day.
  - `insights_memory_media_cards.dart`: back then, media counters, voice and round videos.
- Charts are plain widgets (bars, stacked columns, grids). `fl_chart` and `syncfusion_flutter_charts` were removed.
- Colors: top-level emotions take a fixed palette in `orderIndex` order; nested emotions inherit their root's color.
- Taps open `DayStoriesScreen` with the matching minds (`showsDate: true` puts the date in the header); "open" in a story goes to the root mind's `MindInfoScreen`. Heatmap cells open that day; the streak card opens today.
- Shake (or long-press on the title) opens `InsightsTweakSheet`: checkboxes to hide cards, drag to reorder, Reset.

## How It Works
1. The screen listens to `MindBloc`, `EmotionBloc`, `SettingsBloc` and the gallery indexer's progress.
2. Each build makes an `InsightsPeriod` from the saved period and the locale, runs the calculator and renders the visible cards in the saved order.
3. Changing the period saves it right away; the screen rebuilds from settings.

## Updated Files
- Domain: `lib/domain/services/insights/*`; settings repository/object (+ `.g.dart`).
- BLoC: `settings_event.dart`, `settings_bloc.dart`.
- UI: `insights_screen.dart`, `insights_widget_id.dart`, `widgets/*`; `day_stories_screen.dart` (`showsDate`); `shake_to_tweak_mixin.dart` (`ShakeScreenIds.insights`).
- Removed: `insights_pie_widget.dart`, `insights_top_chart.dart`, `insights_today_minds_widget.dart`, `my_chip_widget.dart`, `fl_chart`, `syncfusion_flutter_charts`, keys `topMinds`, `spectrum`, `showMindsForPeriod`.
- L10n: 54 `insights*` keys in all 12 ARB files.

## Testing
- `test/domain/services/insights/insights_calculator_test.dart`: period ranges and locale week start, comparison, brightest segment, shares and drill-down, pairs, rhythm, streak survival, on this day, media, hours.
- `test/presentation/blocs/settings_bloc/settings_bloc_test.dart`: the layout update keeps other fields.
- Manual: switch periods; tap a bar or chip and check the stories; tap a heatmap day; shake, hide a card, move one, Reset.

## Edge Cases & Considerations
- Minds without emotions count in the counters, activity and media cards, but not in the emotion cards.
- Archived emotions still appear in the shares when minds are tagged with them.
- Library photo/video counts appear only where the gallery index exists (iOS) and only after it has been built.
- "Words" splits on whitespace, so languages without spaces (Japanese, Chinese) count phrases rather than words.
