# Images in Minds

## Overview
A mind (and a reply in a story) can carry up to 10 photos and videos from the photo library, or photos from the camera. Text stays the
main part of a mind: the day feed only marks that a mind has images, and the story shows them as a card above the
text. Images are free for everyone.

## Implementation Details

### 1. Domain Layer
- `MindNoteImage` piece in `mind_note_content.dart`, stored in the note as `<kekimage path="image/<uuid>.jpg"/>`.
  `kMaxMindImages = 10`. Images go first in the note, then `\n` and the text, like audio and video.
- `imagePieces`, `hasImages`; `hasMedia` and `mediaFilePaths` include images, so deleting a mind deletes its files,
  and export/import and the web server pick them up.
- `AppFileRepository.saveImage(bytes)` writes to `user_files/image`; `image` is in `mediaFolderNames` (backups).
  `WebFileRepository` (phone web) refuses it: the web version shows images but can't add them.

### Gallery videos
- A video is a `MindNoteImage` whose path ends in `.mp4` / `.mov` / `.m4v` (`isVideo`), stored in the same
  `<kekimage path="image/<uuid>.mp4"/>` tag, so it shares the 10-item limit, the strip, the grid and the carousel.
  Older app versions see it as a broken image instead of raw text.
- Its first frame is saved next to it as `image/<uuid>.jpg` (`previewRelativePath`, `videoThumbnailPathFor`);
  `mediaFilePaths` lists both, so deleting, backups and the web server carry the preview along.
- Picking: the gallery picker (`pickMedia` / `pickMultipleMedia`) offers photos and videos. Videos longer than
  `kMaxAttachedVideoLength` (60 s) are skipped with a snackbar (`videoTooLong`). The rest are re-encoded to 720p by
  `video_compress` (`VideoQuality.Res1280x720Quality`, audio kept) under a "Compressing video…" dialog, then moved into
  `user_files/image` (`AppFileRepository.moveIntoImages`). The camera option still takes photos only.
- Showing: `MindImageView` draws the preview with a ▶ badge everywhere. `MindImagesFullscreen` plays the video
  (`_FullscreenVideo`) with sound, looping, tap to pause, drag down to close. The story carousel shows the preview;
  a tap opens it full-screen.

### 2. Picking (`lib/presentation/core/widgets/images/mind_images.dart`)
- `pickMindImages` asks "Photo library / Camera" (adaptive action sheet) and saves copies.
- `image_picker` scales to at most 2048 px on the long side, JPEG quality 85. EXIF location is not stripped.
- `MindImageAttaching.fromAsset` copies a day-feed gallery photo (2048 px JPEG thumbnail of the asset).
- Images removed before saving, or left when the editor or story closes, are deleted at once (`discard`).

### 3. UI
- **Editor** (`MindCreatorScreen`): a white 🖼 button left of the record button; `MindImageStrip` above the text:
  long-press drag to reorder, ✕ to remove, tap to view. A mind can be saved with images only. Editing an existing
  mind changes only its text; `mindWithText` keeps the images.
- **Day feed** (`DayFeedMindTile`): "🖼 N" badge in the top-right corner. A mind with images and no text shows its
  first image as the tile.
- **Classic list** (`MindBulletWidget`): `MindImageGrid` above the text.
- **Story** (`_MindPage`): `MindImageCarousel`, a 4:5 card above the text. Swipe on the card pages through the
  images; past the first or last one it goes to the previous or next story (via the overscroll of a clamping
  `PageView`). Tap opens `MindImagesFullscreen` (pinch to zoom, drag down to close) and holds the story.
  The story lasts the reading time plus one photo duration.
- **Replies**: the 🖼 icon inside the reply field; picked photos show above it and are sent with the text.
  A reply shows them as a 120 pt `MindImageGrid` (up to 4 tiles, "+N").
- **Gallery photo menu** in the day feed: "New note with this photo" opens the editor for that photo's day with a
  copy attached. The gallery tile stays.

## Edge Cases & Considerations
- Taps on the card inside the edge tap zones (22% of the width) still go to the previous/next story.
- Older app versions show `<kekimage …/>` as text, as they did with video.
- The Apple Watch app does not show images.

## Analytics

`pickMindImages` and "New note with this photo" send `images_attached {count, source, target}`. No paths, EXIF or
pixels are sent. See `ANALYTICS_IMPLEMENTATION.md`.

## Testing
- `test/domain/services/entities/mind_note_image_test.dart`: parsing, serialization, file paths, text edits.
