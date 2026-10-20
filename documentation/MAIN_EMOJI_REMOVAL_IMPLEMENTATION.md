# Main Emoji Removal Implementation

## Overview
A mind used to have one required "main emoji". Its meaning was never clear (a topic? the main emotion?), and with the emotion tree it competed with emotions. The main emoji is gone from the UI: a mind is text/media plus optional emotions. The old value lives on as `Mind.legacyEmoji` only for migration and CSV.

Phase 1 of three. Phase 2 (gallery index cache) and phase 3 (analytics redesign) are separate.

## Implementation Details

### 1. Domain Layer
- `Mind.emoji` → `Mind.legacyEmoji` (`String?`). Hive field 1 and the CSV column 1 keep their place; JSON key stays `emoji`.
- `Mind.fromCSVEntry` parses a CSV row; an empty emoji column becomes `null`.
- `LegacyEmojiLinker` (`lib/domain/services/emotions/`) tags a mind with the emotion that has its legacy emoji. Rules:
  - root minds only (reflections are plain text);
  - only minds without emotions;
  - only active emotions; top-level wins over nested, then lower `orderIndex`;
  - `❤` and `❤️` match (variation selectors are ignored);
  - no match → nothing changes.
- `EmotionSeeder` holds the ADR-0003 seeding guard so the migration, onboarding and `EmotionBloc` share it.
- `MigrationV4LegacyEmojiToEmotions`: seeds starter emotions first (so common emoji can match), then links. Runs once; later emotions never link retroactively.
- CSV import runs the same linker on imported minds against the current emotions.
- `FrequentEmotions.pick` — most-used active emotions, topped up with top-level ones.
- `DayEmotionSummary` — unique emotion emojis of a day's root minds plus a `•` when some mind has none.
- Settings: `isMindContentVisible` removed; Hive field 0 is retired.
- Onboarding minds are tagged with starter emotions (`OnboardingMindData.emotionEmoji`).

### 2. BLoC Layer
- `MindCreate` has no `emoji`; it takes `emotionIds`.
- Removed: `MindCreatorBloc` (emoji suggestions), `UsedEmojiCubit`, `SettingsChangeMindContentVisibility`, `UserProfileAddFolderMind`.
- `EmotionsList.topLevelEmojisOf(ids)` / `rootOf(emotion)` for insights.

### 3. UI Layer
- Creator: text field, then a row of emotion chips (selected first, then frequent) and an "All…" chip that opens `EmotionMarkingSheet`. Emotions are optional.
- Reflections (mind info bottom bar): text/media only, no emoji picker.
- Mind card, tiles, stories: emotion emojis instead of the main emoji; nothing when the mind has no emotions.
- Calendar week rows and month cells: `DayEmotionsText`.
- Full-screen audio player: a waveform icon instead of the emoji.
- Insights pie and top chart group by top-level emotion; a mind with several emotions counts fully in each. The random-mind widget is removed.
- The emotion editor still picks an emoji through `EmojiPickerScreen` (moved from `mind_picker`).

### Removed features
- "Show all" by emoji (`MindOneEmojiCollectionScreen`), emoji search in the calendar, emoji suggestions.
- Hide-content mode: `SensitiveWidget`, the day-screen eye button, the debug "Sensitive Content" flag, `local_auth` and `NSFaceIDUsageDescription`.
- Watch link: `WatchCommunicationManager` is no longer started; Swift code untouched.

## Testing
- `test/domain/services/emotions/legacy_emoji_linker_test.dart`
- `test/domain/services/emotions/frequent_emotions_test.dart` (also `DayEmotionSummary`)
- `test/domain/services/entities/mind_csv_test.dart`
- `test/domain/migrations/migration_v4_legacy_emoji_to_emotions_test.dart`
- Manual: create a mind with and without chips; open "All…"; check calendar cells show emotion emojis and `•`; import an old CSV and check matching emotions appear.

## Edge Cases & Considerations
- A user who deleted all starter emotions (`hasSeededEmotions == true`) is not re-seeded, so their minds link only to emotions they kept.
- Archived emotions never receive links, but minds already tagged with them still show them.
- The CSV column keeps `legacyEmoji`, so old backups and new exports stay compatible both ways.
