# Hold to Record

## Overview
Audio and round video are recorded like voice messages in Telegram. The round record button records only while the finger holds it. Letting go finishes the recording and adds it at once.

## Implementation Details
### UI Layer
- `MediaRecordToggleButton` (`lib/presentation/core/widgets/round_video/media_recording.dart`):
  - **Tap** switches between audio and round video.
  - **Hold** (250 ms) starts recording.
  - **Release** finishes the recording and calls `onRecorded(piece)`.
  - **Slide left** (120 pt) throws the recording away.
  - **Slide up** (80 pt) locks it. After that the finger can leave the button, and the bar shows delete and send.
  - `onRecordingChanged(bool)` tells the screen that a recording is running.
- The overlay is an `OverlayEntry` in the root overlay, placed from the button's position:
  - a bar with a blinking dot, the timer and "Slide to cancel" (trash when locked);
  - the lock hint above the button;
  - the send button over the button when locked;
  - for video, a dim scrim and the front-camera circle. There is no preview afterwards.
    The circle is flipped horizontally so it matches the recorded (unmirrored) video, and stays blurred until `startVideoRecording` returns, so the sharp picture marks the real start.
- Recorders:
  - `_AudioHoldRecorder` uses `record` with AAC 128 kbps 44.1 kHz into `createAudioFile()`. The duration comes from `AudioDurationExtractor`.
  - `_VideoHoldRecorder` uses `camera` (front, `ResolutionPreset.high`, with audio). It takes a still first and saves it as the thumbnail (`videoThumbnailPathFor`), then records into `createVideoFile(extension: 'mp4')`.
- Callers:
  - `MindCreatorScreen` attaches the piece to the note, so text can be added before saving.
  - The story (`DayItemViewerScreen` → `MindCommentBar`) sends it as a reply right away (`MindComments.sendRecording`). It holds the story while recording.

### Waveform previews
`AudioWaveform` (`lib/presentation/core/widgets/sound/audio_waveform.dart`) draws a recording's loudness as bars from `SoundEnvelope`. Each bar is the average level of its slice, so narrow previews keep their shape. It is used:
- in the story's audio player (`MindAudioWave`), filled as it plays;
- on day-feed tiles of audio minds;
- in voice replies under a story, filled as they play;
- on the recording attached in the editor.

## Edge Cases & Considerations
- The first hold only asks for the microphone, because the system prompt would sit under the finger. That hold records nothing.
- Recordings shorter than 0.7 s are deleted.
- The thumbnail still is taken with the flash off. The front camera's auto flash would otherwise flash the whole screen white right before the circle starts.
- In the editor the attached audio uses the story's player (`MindAudioWave`):
  - full width, no frame;
  - ▶ in the first chosen emotion's color;
  - playable before saving.
- A cancelled or failed recording deletes its files, including the video thumbnail.
- Letting go while the recorder is still starting cancels the recording.
- The old tap-to-start `MindAudioRecorderSheet` and `RoundVideoRecorderScreen` were removed, together with their strings.

## Testing
On a device or simulator:
- Hold the mic for 2 s and let go: an audio reply appears.
- Hold and slide left: nothing is saved.
- Hold and slide up: the bar stays. Delete discards the recording, and the arrow sends it.
- Repeat in video mode on a device; the simulator has no camera.
