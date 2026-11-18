# Mind Creator Emotions Implementation

## Overview
The mind creator (`MindCreatorScreen`) asks for emotions through one round button in the bar above the keyboard, next to the attach-images and record buttons. Save never opens the emotion sheet: a mind saved without picks simply has no emotions, which can be added later from its menu.

The button is set apart from the plain white attach buttons by a ring in the emotion colors (`kEmotionPalette`). Once emotions are picked it grows into a pill showing their emojis. It is hidden while editing an existing text.

There is no shake-to-tweak on the creator any more: the earlier `MindEmotionsPrompt` setting (`afterSave` / `button` / `never`) and its tweak sheet were removed.

## Implementation Details

### 1. Domain Layer
- `MindEmotionsPrompt` and `KeklistSettings.mindEmotionsPrompt` are gone. Hive field 41 of `SettingsObject` is no longer written; old values in it are ignored on read. Don't reuse index 41.
- The `mind_emotions_prompt` analytics property is gone with it.

### 2. UI Layer
- `mind_creator_screen.dart`: `_EmotionsButton` (52 pt, gradient ring, white fill, `Icons.add_reaction_outlined` or the chosen emojis) opens `EmotionMarkingSheet`.
- `ShakeScreenIds.creator` was removed.

## Testing
1. Create a mind: the bar shows emotions, images and record buttons.
2. Tap emotions, pick some: the button shows their emojis; Save attaches them.
3. Save without picking: the mind is created right away with no sheet.
4. Shaking the creator does nothing.
