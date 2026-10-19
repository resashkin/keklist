# Audio & Round Video Minds Implementation

## Overview

A mind (root or reflection) can carry **one** voice message **or** one Telegram-style round video, plus optional text. Previously audio was only possible for reflections.

## Implementation Details

### 1. Domain Layer

- `MindNoteVideo` (`lib/domain/services/entities/mind_note_content.dart`) is a new note piece, serialized as `<kekvideo path="video/<uuid>.mp4" duration="12.5"/>` inside `Mind.note`, the same way `<kekaudio …/>` works. No Hive migration is needed.
- `BaseMindNotePiece.map` gained a required `video` callback, so every renderer handles video explicitly.
- `MindNoteContent` helpers:
  - `videoPieces`, `hasVideo`, `hasMedia`.
  - `mediaFilePaths`: audio files, video files and video thumbnails.
  - `copyWithAppendedVideo`, `withoutMedia`.
- The thumbnail path comes from the video path (`videoThumbnailPathFor`: same name, `.jpg`).
- `AppFileRepository.createVideoFile` stores videos in `user_files/video/`. `mediaFolderNames` lists `audio` and `video`.
- Export writes every file from `mediaFilePaths` into the ZIP under its relative path (`audio/…`, `video/…`). Import copies both folders back.

### 2. BLoC Layer

- `MindBloc._createMind` keeps video pieces.
- Deleting a mind and clearing the cache remove all media files via `mediaFilePaths`.
- New `MindRemoveMedia` event: deletes the files and rewrites the note without media (the "Remove media" action in MindInfo).

### 3. UI Layer

- `MediaRecordToggleButton` (`core/widgets/round_video/media_recording.dart`): **tap** switches between mic and camera (it always starts on mic), and a snackbar hint shows. **Long-press** opens the recorder for the current mode. It has no tooltip on purpose, because a tooltip would capture the long-press.
- `MediaRecording.recordAudio` / `recordVideo` wrap the existing `MindAudioRecorderSheet` and the new `RoundVideoRecorderScreen`, and return note pieces.
- `RoundVideoRecorderScreen`:
  - Front camera by default, with a flip button, recording at 720p (`ResolutionPreset.high`).
  - The live preview is center-cropped into a circle.
  - Tap to start and tap to stop, with no length limit. Then a looping round preview with **Retake** / **Use**.
  - A still is captured right before recording starts and saved as the thumbnail.
- `MindCreatorScreen`: the toggle is the text field's suffix. An attached recording shows above the text with a delete button. Closing without saving deletes the recording. The saved note is `media tag` + `\n` + text.
- MindInfo comment bar (`MindCreatorBottomBar`): the same toggle (`onRecordAudio` / `onRecordVideo`). Recording creates the reflection immediately.
- Editing keeps the mind's media and only changes text and emoji. "Remove media" is a separate action.
- Display:
  - `RoundVideoThumbnail` (static circle) and `RoundVideoMessage` (tap to play or pause, with a progress ring).
  - Used in the root mind card (`MindMessageWidget`, which now also shows root audio), reflection bubbles (`MindBulletWidget`) and the All-mode grid tile (round thumbnail plus emoji badge).
- Stories: video minds play in a circle and audio minds play their audio. Each story lasts as long as its media and follows the same mute and volume-button rule as other videos.

## How It Works

1. Tap the mic to flip to the camera.
2. Long-press to open the recorder.
3. Record, then confirm with **Use**.
4. The piece is attached in the creator, or saved directly as a reflection.
5. Saving creates the note string with the tag. Every list parses it back with `MindNoteContent.parse`.

## Updated Files

- **Domain:** `mind_note_content.dart`, `app_file_repository.dart`, `export_import_service.dart`
- **BLoC:** `mind_bloc.dart`, `mind_event.dart`
- **UI (new):** `core/widgets/round_video/round_video_recorder_screen.dart`, `round_video_views.dart`, `media_recording.dart`
- **UI (changed):** `mind_creator_screen.dart`, `mind_creator_bottom_bar.dart`, `mind_info_screen.dart`, `mind_message_widget.dart`, `mind_bullet_widget.dart`, `day_feed_tiles.dart`, `day_stories_screen.dart`, `settings_screen.dart`
- **Platform:** `ios/Runner/Info.plist` (camera and mic texts), `AndroidManifest.xml` (`CAMERA`, `RECORD_AUDIO`)
- **Dependencies:** `camera`
- **Localization:** 7 keys in all 12 ARB files

## Testing

- Unit: `test/domain/services/entities/mind_note_content_test.dart` covers video parsing, round-trip, media paths, `withoutMedia`, and rejecting an invalid duration.
- Manual (real device, since the simulator has no camera):
  1. Create a video mind and an audio mind from the day screen.
  2. Add a video reflection in MindInfo.
  3. Check the grid tile, root card, bubbles and stories.
  4. Run "Remove media".
  5. Export and import, then check the videos come back.

## Edge Cases & Considerations

- Older app builds do not know `<kekvideo>`. They render it as unsupported or raw text, for example after importing a backup on another device.
- `video_thumbnail` was not used because it has no Swift Package Manager support. This iOS project is SwiftPM-only, with no Podfile.
- Import still reports `audioFilesCount`, which now also counts videos and thumbnails.
- Front-camera thumbnails come from a still photo, so they can be mirrored differently from the video.
