# What's New and Rating Implementation

## Overview
After a major update, and on a new install, the app shows a What's New sheet once, before the user starts. The
sheet has slides with short looping clips. Later the app asks once for a store review, and Settings has a
"Rate keklist" row. All of this helps the store rating.

## Implementation Details

### 1. Domain Layer
- `KeklistSettings` gets three fields, stored in `SettingsObject` Hive slots 50–52:
  - `whatsNewSeenRelease`: the last release whose sheet was shown.
  - `whatsNewSeenAt`: when it was shown. The review prompt counts minds from this moment.
  - `reviewPromptedRelease`: the release in which the review prompt was last requested.
- Slot 1 (`previousAppVersion`, from the old What's New web page) stays reserved and unused.
- `KeklistConstants.appStoreId` is the App Store id that the Rate row opens.

### 2. BLoC Layer
- `SettingsMarkWhatsNewSeen(release)` stores the release and the current time.
- `SettingsMarkReviewPrompted(release)` stores the release.

### 3. UI Layer
- `screens/whats_new/whats_new_release.dart`:
  - `WhatsNewRelease.release` (now `'6.0'`) and the slides.
  - `shouldShow` and `shouldAskForReview` contain the rules, so tests can check them without widgets.
- `screens/whats_new/whats_new_sheet.dart`:
  - A `KekSheet` that fills 90% of the screen.
  - Horizontal swipe between slides, page dots, Next, and Start on the last slide.
  - ✕ or a swipe down closes the sheet.
  - Each clip is muted, loops, and plays only while its slide is visible. It mixes with other audio.
- `screens/whats_new/release_prompts.dart`: the `ReleasePrompts` mixin on `TabsContainerScreen` starts both
  prompts.
- Settings → Support → "Rate keklist":
  - It calls `InAppReview.openStoreListing`, which opens the write-review page on iOS and the Play listing on
    Android.
  - The row is hidden in the web version.

### 4. Assets
- The clips are in `assets/whats_new/{web,gallery,circles,shake}.mp4`.
- Each clip is muted H.264, 5–8 s, at most about 1.5 MB, recorded in the English UI on a clean simulator with
  "Show Touches" on.
- `pubspec.yaml` declares the folder with `platforms: [android, ios]`, so the clips are not in the web bundle.

## How It Works
1. `TabsContainerScreen` subscribes to `SettingsBloc` and sends `SettingsGet`. The bloc starts with placeholder
   settings, so the first state after that event is the first one that comes from storage.
2. If `whatsNewSeenRelease != WhatsNewRelease.release`, the app first marks the release as seen and then shows
   the sheet. Any close counts as seen, and so does a crash while the sheet is open.
3. On each `MindList`, the app asks for a review when all of these are true:
   - What's New of this release was seen.
   - It is not the same day.
   - The user has made at least 5 minds since then, not counting onboarding minds.
   - The app did not ask in this release yet.

   The release is marked as prompted before the request. `InAppReview.requestReview` lets the OS decide whether to
   show the review prompt: Apple limits it to 3 times a year.
4. The web version (`kIsPhoneWeb`) shows neither the sheet nor the prompt.

## Next Major Release
1. Set `WhatsNewRelease.release`.
2. Replace the slides, their ARB keys (`whatsNew*`) and the clips.
3. Users who saw the old release see the new one once. The review prompt can come again in that release.

## Analytics
These events contain no mind content:
- `whats_new_shown`
- `whats_new_completed` / `whats_new_skipped`, with the slide number it closed on
- `rate_tapped`
- `review_prompted`

See `ANALYTICS_IMPLEMENTATION.md`.

## Updated Files
- Domain:
  - `settings_repository.dart`
  - `object/settings_object.dart` and `object/settings_object.g.dart`
  - `constants.dart`
  - `analytics.dart`
- BLoC: `settings_bloc.dart`, `settings_event.dart`.
- UI:
  - `screens/whats_new/*`
  - `tabs_container_screen.dart`
  - `settings_screen.dart` and `settings_layout.dart`
- `pubspec.yaml`: `in_app_review` and the `assets/whats_new/` folder.
- `lib/l10n/app_*.arb`: `whatsNew*` and `rateApp`, in 12 languages.

## Testing
- `test/presentation/screens/whats_new/whats_new_release_test.dart` covers the show and review rules.
- Manual check of the sheet: install or update, and the sheet appears once. Kill the app and open it again, and
  the sheet stays hidden.
- Manual check of the review prompt: StoreKit shows the prompt every time in debug builds and in TestFlight it
  shows nothing. To test the rule, change the date or lower `mindsBeforeReviewPrompt`.

## Edge Cases & Considerations
- If a clip is missing or fails to load, the slide shows an empty rounded frame instead of crashing.
- New installs see the sheet too. The onboarding minds are created behind it.
