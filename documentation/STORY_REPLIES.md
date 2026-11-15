# Story Replies Implementation

## Overview
Comments of a mind are shown like replies to an Instagram story: the story stays in the background, the last
replies float over its bottom, and the input sits under them. The comments bottom sheet is gone.

## Implementation Details
- `lib/presentation/screens/mind_day_collection/widgets/day_feed/mind_comments.dart`
  - `MindReplies`: the replies, newest at the bottom, avatar on the left; about `StorySettings.replyCount` fit,
    older ones scroll up under a fade. Voice replies play in place, round videos are small circles. Long-press a
    reply for its menu (edit, emotions, remove media, delete).
  - `MindCommentBar`: the input with one round button that sends text, or records audio or video.
- `day_item_viewer_screen.dart`: the viewer keeps the reply controller and focus. While the field has focus the
  story waits (like Instagram) and a tap on the story only hides the keyboard. Only the reply panel follows the
  keyboard (`resizeToAvoidBottomInset: false`).
- `StorySettings` (Hive fields 54–60): reply count, bubble brightness, text size, avatar size (0 hides it), side
  and time, plus the brightness of the emotions behind the story. All are in the story shake sheet
  (`story_texture_tweak_sheet.dart`).

## Testing
Open a story of a mind with comments, type a reply and send it; switch the side, sizes and count in the shake
sheet.

## Edge Cases & Considerations
- Pages change by tapping the right or left edge; the input and replies sit below those tap areas.
- Typing text clears when the page changes.
