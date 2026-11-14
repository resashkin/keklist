# Deferred Autofocus Implementation

## Overview
Sheets and pages that open with a text field used `autofocus: true`, so the keyboard slid up while the sheet was
still sliding in. Each frame then laid the sheet out for both animations (its own position and the shrinking
`viewInsets` that `KekSheetScaffold` pads by), and the opening stuttered. `DeferredAutofocus` waits until the route
has finished opening and only then focuses the field.

## Implementation Details
- `lib/presentation/core/widgets/deferred_autofocus.dart`: owns a `FocusNode`, gives it to its builder, and calls
  `requestFocus()` when `ModalRoute.of(context).animation` completes, or on the next frame if the route is already
  open (for example a field rebuilt inside an open page).
- Used instead of `autofocus: true` in:
  - `mind_creator_screen.dart` (full-screen creator, also used to edit a mind's text);
  - `feedback_sheet.dart`;
  - `emotion_editor_sheet.dart`;
  - `emoji_picker_screen.dart` (profile emoji sheet);
  - `password_input_bottom_sheet.dart` (export/import password);
  - `debug_menu_screen.dart` (developer password dialog).

## Testing
- `test/presentation/core/widgets/deferred_autofocus_test.dart`: no focus while the sheet animates, focus after.
- Manually: open each sheet above; the sheet slides up first, then the keyboard, without a hitch.

## Edge Cases & Considerations
- New text fields that should open with the keyboard use `DeferredAutofocus` instead of `autofocus: true`.
- The keyboard now appears about 250–300 ms later (the route's transition time).

## Performance Test
`integration_test/keyboard_sheet_perf_test.dart` opens a sheet with a text field over the demo Today screen and
slides a simulated keyboard in, either together with the sheet or after it, five times each. It reports frame
times and widget rebuilds to `build/integration_response_data.json`:
```bash
fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/keyboard_sheet_perf_test.dart \
  -d <simulator> --dart-define=KEKLIST_SCREENSHOTS=true
```
The test fails if more than 100 widgets outside the sheet rebuild per opening while the keyboard moves.

## Keyboard Insets Barrier
The keyboard's bottom inset changes on every frame of its animation. Before the fix the whole Today screen under
the sheet rebuilt on each of those frames (about 7,500 widgets per opening): the tabs' `Scaffold` shrank its body to
avoid the keyboard and everything reading `MediaQuery` below it followed. The tabs have no text fields of their own
(they open sheets and pages for input), so `TabsContainerScreen` wraps its layout in `KeyboardInsetsBarrier`
(`lib/presentation/core/widgets/keyboard_insets_barrier.dart`), which shows the tabs a `MediaQuery` without the
keyboard. Sheets and pushed pages are separate routes and still see the keyboard.

Debug, iPhone 17 Pro Max simulator, per opening (keyboard after the sheet):

| | Before | After |
|---|---|---|
| Widget rebuilds outside the sheet | ~7,500 | ~80 (root `MediaQuery`, the barrier, the sheet route's wrappers) |
| All widget rebuilds | ~8,500 | ~1,100 |
| Frames over 16.7 ms (5 openings) | 32 | 2 |
| Worst frame build | 47 ms | 24 ms |

Debug numbers are only good for comparing runs; check smoothness on a device in a release build.

A new screen that has a text field directly in a tab body (not in a sheet or a pushed page) would need its own
keyboard handling, since the barrier hides the keyboard from it.
