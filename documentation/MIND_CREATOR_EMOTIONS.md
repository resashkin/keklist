# Mind Creator Emotions Implementation

## Overview
The mind creator (`MindCreatorScreen`) no longer lists emotion chips under the text. How it asks for emotions is a per-user choice, set by shaking the creator (shake-to-tweak, screen id `creator`):

| `MindEmotionsPrompt` | Behaviour |
|---|---|
| `afterSave` (default) | Save opens the emotion sheet; closing it (with or without picks) creates the mind with what was picked |
| `button` | An "Emotions" button above the keyboard opens the sheet; it shows the chosen emojis |
| `never` | Nothing; emotions are added later from the mind's menu |

The record button is a round white button at the right edge above the keyboard. It shows only while the text is empty and no media is attached: a tap switches audio/video, a long press records, as before.

## Implementation Details

### 1. Domain Layer
- `settings_repository.dart`: `MindEmotionsPrompt` and `KeklistSettings.mindEmotionsPrompt`.
- `settings_object.dart`: `@HiveField(41) mindEmotionsPromptIndex` (default 0 = `afterSave`).

### 2. BLoC Layer
- `SettingsUpdateMindEmotionsPrompt` updates the setting through `SettingsRepository.updateSettings`.

### 3. UI Layer
- `mind_creator_screen.dart`: the text area scrolls; a bar pinned above the keyboard holds the emotions button (mode `button`) and the record button.
- `mind_creator_tweak_sheet.dart`: the three modes as radio rows.
- `MediaRecordToggleButton.isFilled`: the white round style.

## Updated Files
- `lib/domain/repositories/settings/settings_repository.dart`, `object/settings_object.dart` (+ `.g.dart`)
- `lib/presentation/blocs/settings_bloc/settings_bloc.dart`, `settings_event.dart`
- `lib/presentation/screens/mind_creator/mind_creator_screen.dart`, `mind_creator_tweak_sheet.dart`
- `lib/presentation/core/widgets/round_video/media_recording.dart`, `lib/presentation/core/shake/shake_to_tweak_mixin.dart`
- All 12 ARB files: `creatorEmotions*` added, `allEmotions` removed.

## Testing
1. Create a mind and type: the record button disappears; clear the text: it comes back.
2. Save: the emotion sheet opens; pick one, close it; the mind has that emotion.
3. Shake the creator, pick "Button above the keyboard": the button appears and shows chosen emojis.
4. Pick "Don't ask": Save creates the mind right away.

## Edge Cases & Considerations
- The web version served by the phone has no recording, so it never shows the record button.
- The chosen emotions are attached before the mind is created, so no second write is needed.
