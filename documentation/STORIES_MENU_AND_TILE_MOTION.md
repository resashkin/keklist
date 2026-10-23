# Stories, Tile Context Menu and Tile Motion Implementation

## Overview
One stories screen for every way of looking at a day, a native long-press menu on every tile, slowly moving
emotion emojis on mind tiles, and an animated pinch that resizes the grids without scrolling them.

## Implementation Details

### 1. One stories screen
`DayItemViewerScreen` (`widgets/day_feed/day_item_viewer_screen.dart`) replaces both the old viewer and
`DayStoriesScreen`, which is deleted.
- Segments on top, one per item. A tap on a tile opens it still: the current segment is simply lit.
- `autoplay: true` (▶ on a day, a week or the day screen) runs a timer per item. Minds last
  `DayFeedLayout.mindStoryDuration`, audio minds their audio, photos `photoStoryDuration`; videos report their
  length once loaded (`_onMediaDuration`). Holding pauses the timer and the media; the last item closes the screen.
- Navigation: the left and right 22% of the page are translucent tap zones (they win over the text's tap), swipes,
  arrow keys; Space pauses with the timer, Esc closes. Wide screens get a 9:16 card in the middle.
- Emotions: the pill under the text is gone, the texture behind the mind shows them. Long press on the background
  (without the timer) or pushing a mind up past its end opens `EmotionMarkingSheet`.
- The comment field is the chat's input bar (`_CommentBar`): rounded field, one white button that sends the text
  or records audio/video while the field is empty.

### 2. Tile context menu
`DayFeedTileMenu` (`widgets/day_feed/day_feed_tile_menu.dart`) wraps every tile of the day sliver and the calendar
grids with `ContextMenuWidget` from `super_context_menu`: a real `UIContextMenu` on iOS (Liquid Glass on iOS 26,
SF Symbols, the tile lifted as preview), native menus on Android and desktop, nothing on the web.
- Mind: Edit (text sheet, keeps media via `mindWithText`), Emotions, Share (text), Delete (confirmation).
- Library photo/video: Share (original file), Show in Gallery, Delete. Delete goes through
  `PhotoManager.editor.deleteWithIds`, so the system confirms and keeps it in Recently Deleted;
  `DayFeedTileMenu.mediaDeleted` then makes the day screen reload and the calendar rebuild its index.
- Folder file (Android): Share.
- iOS has no public API to open Photos at one photo, so Show in Gallery opens the Photos app there
  (`photos-redirect://`); Android opens the photo's content URI.

`super_native_extensions` has no Swift package, so iOS now builds plugins through Swift Package Manager plus
CocoaPods for this one plugin (`ios/Podfile`, platform 16.4, no RunnerTests target).

### 3. Tile motion
Two settings in `KeklistSettings` (Hive fields 42 and 43), changed with `SettingsUpdateTileMotion` from
`TileMotionTweaks`, shown in the day and calendar shake sheets:
- `TileEmojiMotion` — `drift` (default), `float`, `still`. `MindEmotionTexture` paints the pattern with a
  `CustomPainter` driven by one controller per tile. Drift moves the tilted pattern by one column and two rows per
  12 s; the emoji of a cell depends on `column - row ~/ 2`, so the loop has no seam. Float sways every emoji on its
  own phase. Reduce Motion keeps it still.
- `GridResizeAnimation` — `fly` (default), `zoom`, `crossfade`. `ResizableTileGrid` lays tiles out in a `Stack`:
  fly animates each tile's `AnimatedPositioned` (keyed by item id) to its new place, crossfade switches layouts with
  `AnimatedSwitcher`. Zoom lives in `PinchColumnsDetector`: the grid scales with the fingers and the column count
  changes on release by the number of 1.3× steps.

`PinchColumnsDetector` now takes a `builder(context, isPinching)`; the day screen and the calendar switch their
scroll physics to `NeverScrollableScrollPhysics` while two fingers are down.

## Updated Files
- Domain: `settings_repository.dart`, `object/settings_object.dart` (+ `.g.dart`).
- BLoC: `settings_event.dart`, `settings_bloc.dart`.
- Core widgets: `mind_emotion_texture.dart`, `pinch_columns_detector.dart`, `resizable_tile_grid.dart` (new),
  `tile_motion_tweaks.dart` (new), `helpers/mind_text_edit.dart` (new).
- Day feed: `day_item_viewer_screen.dart`, `day_feed_tile_menu.dart` (new), `day_feed_sliver.dart`,
  `day_feed_grid.dart`, `day_feed_settings_bottom_sheet.dart`, `mind_audio_circle.dart`, `mind_story_details.dart`;
  `day_stories_screen.dart` and `creator_bottom_bar/` deleted.
- Screens: `mind_day_collection_screen.dart`, `mind_collection_screen.dart`, `mind_collection_body.dart`,
  `calendar_settings_bottom_sheet.dart`.
- iOS: `Podfile`, `Flutter/*.xcconfig`, `project.pbxproj`.
- Strings: `showInGallery`, `tileEmojiMotion*`, `gridResize*` added; `dayFeedMute`, `dayFeedUnmute` removed.

## Testing
- Tap a tile: segments on top, nothing moves on its own; edge taps and swipes move, long press opens emotions.
- ▶ on a day: segments fill, items advance, holding pauses, the last one closes.
- Long-press tiles of each kind and try every action; deleting a photo asks the system first.
- Shake on the day screen or calendar, switch Emoji motion and Pinch animation, pinch the grid.

## Edge Cases & Considerations
- The day grid is no longer lazy (a `Stack` in a box) so tiles can fly; a day rarely holds more than a few hundred.
- Videos play with sound in both modes; the old stories' session mute is gone.
- Delete of a mind removes its comments too (`MindDelete`).
