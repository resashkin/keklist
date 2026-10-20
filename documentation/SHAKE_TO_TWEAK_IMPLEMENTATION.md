# Shake to Tweak Implementation

## Overview

Screens no longer carry "tweak" buttons. Shaking the phone opens the screen's customization sheet. Long-pressing the AppBar title does the same, for devices or situations where shaking is not practical (simulators, tablets on a desk, accessibility).

Screens using it:

| Screen | Shake / long-press title opens |
|---|---|
| Day (`MindDayCollectionScreen`) | `DayFeedSettingsBottomSheet` (tiles, weather, Android media folder) |
| Settings (`SettingsScreen`) | `SettingsCustomizeBottomSheet`: checkboxes for every section and row |

Until the user has used the gesture once on a screen, a "Shake to customize" toast with a shaking-phone icon appears on that screen, at most once per app launch.

The "+ Write" button label (`create` l10n key) is now "+ Create" in all languages.

## Implementation Details

### 1. Domain Layer

- `SettingsObject` Hive fields:
  - 26 `hiddenSettingsItemIds` (`List<String>`, default empty)
  - 27 `shakeDiscoveredScreenIds` (`List<String>`, default empty)
- `KeklistSettings.hiddenSettingsItemIds` / `shakeDiscoveredScreenIds` expose them as `Set<String>`.
- `SettingsRepository.updateSettingsItemHidden(id, isHidden:)` and `markShakeDiscovered(String screenId)`. Both change the stored list in place (no write when nothing changes), so quick taps in the sheet cannot overwrite each other with a stale set.
- `MigrationRunner`, `SettingsBloc._enableDebugMenu` and `LazyOnboardingBloc` pass both values through when they rebuild `KeklistSettings`.

### 2. BLoC Layer

- `SettingsUpdateItemHidden(id:, isHidden:)` hides or shows one section or row.
- `SettingsMarkShakeDiscovered(screenId:)` marks a screen as discovered.

### 3. UI Layer

- `lib/presentation/core/shake/shake_detector.dart`: pure logic. A reading counts as a peak when the acceleration magnitude is at least `thresholdGravity` (2.7 g, gravity included). Two peaks within 800 ms are a shake; after a shake, readings are ignored for 1.5 s.
- `lib/presentation/core/shake/shake_to_tweak_mixin.dart`: `ShakeToTweakMixin` for any `State`. A screen implements `shakeScreenId` and `onShakeToTweak()`, and wires `requestTweak` to its title's `onLongPress`.
  - Listens to `accelerometerEventStream` (`sensors_plus`) only while `TickerMode` is enabled, so hidden `IndexedStack` tabs and screens under an opaque route do not listen.
  - A shake is ignored when the screen's route is not current, so a shake while a sheet is open does not open another one.
  - `requestTweak()` hides the toast, sends `SettingsMarkShakeDiscovered` and calls `onShakeToTweak()`.
- `lib/presentation/core/shake/shake_hint_toast.dart`: the toast. Inserted into the `Overlay` below the AppBar 1.2 s after the screen becomes visible, removed after 5 s, on tap, on `requestTweak`, or when the screen is hidden.
- `ShakeScreenIds` holds the per-screen ids (`day`, `settings`).
- Settings screen:
  - `settings_layout.dart`: `SettingsItemIds` (stable string ids, `section.*` and `row.*`), `SettingsSectionModel` / `SettingsRowModel`, and `visibleExcept(hiddenIds)`.
  - `SettingsScreen` builds its sections as models once, renders `visibleExcept(hidden)`, and passes the full list to the customize sheet.
  - A section is hidden when its own id is hidden or when all of its rows are hidden.
  - Conditional rows (`pro` vs `proStatus`, `debugMenu`) appear in the sheet only when they would appear on the screen.
- Day screen: the AppBar `tune` icon, the "Sources" text button and the Sources/All toggle are gone. Only the sensitive-content eye stays.

## How It Works

1. The screen becomes visible → the mixin subscribes to the accelerometer and, if the toast was not shown this launch, schedules it.
2. When the timer fires, the toast is shown only if the screen is still frontmost and `shakeDiscoveredScreenIds` lacks the screen id.
3. A shake (or a long press on the title) → `requestTweak()` → screen id is persisted as discovered → the screen's sheet opens.
4. In the Settings customize sheet, each checkbox toggles one id in `hiddenSettingsItemIds`; the screen behind updates live through `SettingsBloc`.

## Updated Files

**Domain**
- `lib/domain/repositories/settings/object/settings_object.dart` (+ `.g.dart`)
- `lib/domain/repositories/settings/settings_repository.dart`
- `lib/domain/repositories/settings/settings_hive_repository.dart`
- `lib/domain/migrations/migration_runner.dart`

**BLoC**
- `lib/presentation/blocs/settings_bloc/settings_bloc.dart`, `settings_event.dart`
- `lib/presentation/blocs/lazy_onboarding_bloc/lazy_onboarding_bloc.dart`

**UI**
- `lib/presentation/core/shake/` (new): `shake_detector.dart`, `shake_to_tweak_mixin.dart`, `shake_hint_toast.dart`
- `lib/presentation/screens/settings/settings_layout.dart` (new)
- `lib/presentation/screens/settings/widgets/settings_customize_bottom_sheet.dart` (new)
- `lib/presentation/screens/settings/settings_screen.dart`
- `lib/presentation/screens/mind_day_collection/mind_day_collection_screen.dart`

**Localization**: `create` renamed to "Create"; new keys `shakeToCustomize`, `shakeToCustomizeHint`, `customizeSettings`, `customizeSettingsDescription` in all 12 ARB files.

**Platform / dependencies**: `sensors_plus` (ships a Swift package, so the iOS project stays SwiftPM-only); `NSMotionUsageDescription` added to `ios/Runner/Info.plist` because the plugin links CoreMotion and its README requires the key.

## Testing

- Unit:
  - `test/presentation/core/shake/shake_detector_test.dart`: threshold, peak window, cooldown, custom parameters.
  - `test/presentation/screens/settings/settings_layout_test.dart`: row/section hiding, empty sections, unknown ids, id uniqueness.
- Manual (real device):
  1. Fresh install → Day screen shows the toast after about a second; shake → sheet opens; toast never returns on that screen.
  2. Settings tab → toast appears there too; long-press the title → customize sheet.
  3. Uncheck a row and a section → they disappear behind the sheet; restart the app → still hidden.
  4. Shake while a sheet is open → nothing new opens.
- The iOS Simulator's Device → Shake sends a `UIEvent` motion event, not accelerometer data, so it does not trigger this detector. Use the long-press fallback there.

## Edge Cases & Considerations

- Hiding every section leaves Settings empty; shaking or long-pressing the title is still available to bring rows back.
- The Settings title tap still counts towards enabling the debug menu; long press is a separate gesture.
- Ids are stored as strings, so removing a row from code leaves a harmless stale id in `hiddenSettingsItemIds`.
- If `SettingsBloc` is not in `SettingsDataState` when the toast timer fires (e.g. mid-export), the toast is skipped and retried on the next visit to the screen.
- The accelerometer stream's errors (no sensor, web without motion permission) are ignored; the long-press fallback keeps working.
