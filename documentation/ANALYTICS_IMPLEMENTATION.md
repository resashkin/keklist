# Analytics Implementation

## Overview

Anonymous usage analytics and remote feature flags through PostHog (EU cloud, project `keklist`).
Analytics collects which tweaks people choose, which screens they open, paywall and tip events, and crashes.
It never sends minds or anything derived from them. It is on by default and can be turned off in
Settings → Analytics.

## Implementation Details

### 1. Domain Layer

- `lib/domain/services/analytics/analytics.dart`: the `Analytics` facade. Every call does nothing unless
  `Analytics.isSupported` is true: a release build, not web, with `POSTHOG_API_KEY` in `dotenv`.
- `lib/domain/services/analytics/analytics_payloads.dart`: pure functions, covered by tests.
  - `analyticsTweaksOf(settings)`: the whitelist of tweaks. It holds only enum names, bools and numbers.
  - `changedTweaks(previous, current)`: the tweaks that differ between two snapshots.
  - `withoutExceptionMessages(properties)`: drops exception messages and keeps the type and stack.
- `SettingsObject` HiveField 49 is `isAnalyticsEnabled`, default `true`. `KeklistSettings.isAnalyticsEnabled`
  mirrors it.
- `DebugMenuType.forceAiChat` shows the Chat tab whatever the flag says.

### 2. BLoC Layer

- `SettingsSetAnalyticsEnabled` stores the switch, then calls `Analytics.setEnabled`.
- The `SettingsBloc` listener on the settings repository calls `Analytics.settingsChanged`, which sends one
  `tweak_changed` per changed tweak.
- `TabsContainerBloc` hides the `ai` tab unless `Analytics.isAiChatFlagOn` or `forceAiChat` is on.

### 3. UI Layer

- Settings → Application → **Analytics** row: a switch, and a tap opens `AnalyticsSettingsScreen`.
- `AnalyticsSettingsScreen` shows the switch, what is sent, what is never sent, and "Reset anonymous ID".
- The AI section in Settings shows only while the Chat tab is available.

## How It Works

1. `main.dart` calls `Analytics.setUp(settings)` after DI. It configures PostHog with:
   - `personProfiles = never`: events only, with no person records.
   - No lifecycle autocapture, session replay, surveys, rage clicks or `$feature_flag_called` events.
   - `optOut` if the user turned analytics off.
   - Flutter and platform dispatcher errors captured, and a `beforeSend` that strips exception messages.
2. When enabled, it sends `app_opened` with the full tweak snapshot.
3. Screens: tab switches and shake-to-tweak screens call `Analytics.screenViewed`, which sends `$screen`
   (deduped).
4. Tweaks: each change sends `tweak_changed {key, value, screen}`.
5. Paywall: `paywall_shown {tips_only}`, `tip_purchased {product_id}` and `pro_purchased {product_id}`.
6. Flags: `onFeatureFlags` reads `ai-chat` into `Analytics.isAiChatFlagOn`. The flag is false while analytics
   is off, before PostHog answers, and on unsupported builds.

### Events

| Event | Properties |
|---|---|
| `app_opened` | every key from `analyticsTweaksOf` |
| `$screen` | `$screen_name` |
| `tweak_changed` | `key`, `value`, `screen` (the last viewed screen, if any) |
| `paywall_shown` | `tips_only` |
| `tip_purchased` / `pro_purchased` | `product_id` |
| `$exception` | type and stack frames, without the message |

PostHog adds its own device properties, such as app version, OS and locale. The project has
"Discard client IP data" on.

### Feature flag `ai-chat`

- It gates the Chat (AI) tab. It was created inactive, so the tab is off for everyone.
- To roll it out, enable the flag in PostHog. It has a single 100% release condition, so it can be narrowed
  first.
- For testing, use Debug menu → **Force AI Chat**.

## Updated Files

- Domain: `analytics.dart`, `analytics_payloads.dart`, `settings_object.dart` (+ `.g.dart`),
  `settings_repository.dart`, `debug_menu_repository.dart` and its Hive implementation.
- BLoC: `settings_bloc.dart`, `settings_event.dart`, `tabs_container_bloc.dart`.
- UI: `settings_screen.dart`, `analytics_settings_screen.dart`, `shake_to_tweak_mixin.dart`, `ai_screen.dart`,
  `paywall_bottom_sheet.dart`, the debug menu screen.
- Platform: `com.posthog.posthog.AUTO_INIT = false` in `ios/Runner/Info.plist` and `AndroidManifest.xml`,
  because the Dart side sets PostHog up.
- `main.dart`, `pubspec.yaml` (`posthog_flutter`), ARB files (`analytics*` keys, 12 languages).

## Testing

- Unit: `test/domain/services/analytics/analytics_payloads_test.dart` checks:
  - Tweak values are plain.
  - Hidden media ids, coordinates and the folder path never leak.
  - `changedTweaks` returns only the tweaks that differ.
  - Exception messages are stripped.
- Manual: debug builds send nothing. To see events, temporarily drop `kReleaseMode` from `isSupported`, run the
  app, then check PostHog → Activity:
  - `app_opened`, then `$screen` on tab switches.
  - `tweak_changed` after changing a theme or tweak (events are batched, so allow about 30s).

## Edge Cases & Considerations

- Never add a tweak whose value can contain user text, ids, paths or coordinates. Map it to a bool instead,
  like `media_folder_enabled`.
- Turning analytics off calls `optOut` and also turns the AI flag off, so the Chat tab hides.
- "Reset anonymous ID" calls `Posthog().reset()`, so later events can't be linked to earlier ones.
- Web is never supported; the web build has no PostHog setup.
