# Day Switching

## Overview
The Today screen moves between days with chevrons inside the date bubble and a horizontal swipe over the feed. Both slide the day out and the next one in. This replaces the old pull-past-the-edge (overscroll) switching.

## Implementation Details
### UI Layer
- `lib/presentation/screens/mind_day_collection/widgets/day_switcher.dart`
  - `DaySlideController`: one `AnimationController` from -1 to 1. `slide(forward:, onSwap:)` slides the content out (140 ms), swaps the day, then slides the new day in from the other side (220 ms).
  - `DaySwipeArea`: wraps the feed and applies the slide (a quarter of the width plus a fade). A one-finger horizontal fling (≥ 300 px/s) or drag (≥ 80 px) steps a day. Swiping left opens the next day. A drag that ever had two fingers on the screen is ignored, so pinch-to-change-columns never switches the day.
  - `DaySwitcherTitle`: ‹ date › inside the `GlassAppBar` title bubble. The date slides in the same direction as the day. Tapping the date still opens the calendar picker.
- `GlassAppBar.titlePadding` lets the day screen tighten the bubble around the chevrons.
- `MindDayCollectionScreen._slideToDay` is the single entry point: chevrons, swipe, the calendar picker and `goToToday` all go through it. It ignores taps while a slide is running and gives a selection haptic.

## Edge Cases & Considerations
- `OverscrollListener` was removed together with its scroll-to-top/bottom switching helpers.
- The feed keeps its bouncing physics. Only the day switching on overscroll is gone.
- Localization keys: `previousDay`, `nextDay` (chevron tooltips).
