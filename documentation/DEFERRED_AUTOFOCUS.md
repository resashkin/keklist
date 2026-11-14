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
