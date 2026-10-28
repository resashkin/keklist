# Insights Profile Header Implementation

## Overview
Insights now opens like a profile: avatar, name and "Mindful for N days" above the analytics. The profile is kept
only on this device. The separate Profile tab is gone. The period is picked with a frosted sliding switcher.

## Implementation Details
### 1. Domain Layer
- `UserAvatar` (`settings_repository.dart`): `emoji` or `imagePath`, both null for the name's initial.
  Hive fields 39 (`avatarEmoji`) and 40 (`avatarImagePath`); `SettingsRepository.updateUserAvatar`.
- `AppFileRepository.saveAvatarImage` copies the picked photo into `user_files/avatar/` (replacing the previous one)
  and returns the relative path. The avatar folder is not part of export.
- `TabType.profile` was removed. `TabsSettingsSharedPreferencesRepository` drops unknown tab names before decoding and
  clamps the default tab index, so old stored settings that still name `profile` keep loading.

### 2. BLoC Layer
- `UserProfileBloc` now takes `AppFileRepository`; state = `nickname`, `avatarEmoji`, `avatarImage` (resolved `File`).
- Events: `UserProfileGet`, `UserProfileUpdateNickName`, `UserProfileUpdateAvatar(emoji?, photo?)`.

### 3. UI Layer
- `InsightsProfileHeader` (`insights/widgets/insights_profile_header.dart`): centered 88pt `UserAvatarView`, name
  (placeholder "Name"), and `profileMindfulDays` = distinct days with at least one mind. Scrolls with the cards.
- Tapping it opens `ProfileEditSheet`: avatar preview, Photo (`image_picker`, 512px max) / Emoji (`EmojiPickerScreen`)
  / Letter chips, and a name field saved as you type.
- `GlassSegmentedSwitcher` (`core/widgets/glass_segmented_switcher.dart`) replaces the `SegmentedButton`: the thumb
  springs between segments, follows the finger while dragged and ticks a selection haptic on each step; the period is
  committed when the finger lifts.
- `UserProfileScreen` was deleted with its l10n keys (`profileDescription`, `updateYourNickname`, `yourNickname`).

## How It Works
1. The bloc listens to settings; a change of name or avatar re-reads and resolves the photo file.
2. Picking a photo copies it into the app folder, then stores the relative path; picking an emoji clears the photo.

## Testing
- Manual (iPhone 17 simulator): name, emoji, photo and letter avatars; tap and drag the switcher.
- `fvm flutter test` — no new unit tests here; the switcher and sheet are UI-only.

## Edge Cases & Considerations
- The photo is not cropped; it is shown with `BoxFit.cover` in a circle.
- A missing photo file falls back to the emoji or the initial.
