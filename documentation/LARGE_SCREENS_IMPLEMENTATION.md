# Large Screens Implementation

## Overview
keklist runs on the inner screen of iPhone Duo, iPads, Android tablets and Googlebooks with the same layout as the
web version: a navigation rail on the left and content limited to a readable column. A keyboard and a mouse work
for the main actions. No two-pane (list + details) layouts.

## Implementation Details
### 1. Layout (`screens/tabs_container/tabs_container_screen.dart`)
- At 600 logical px and wider (the Material "medium" window class) the tabs become a `NavigationRail`. Below that,
  the usual bottom tab bar. The outer iPhone Duo screen and phones in portrait get the tab bar; the inner Duo screen
  (about 669 pt wide), tablets, Googlebooks and phones in landscape get the rail.
- Content is capped at 840 px and centered, so nothing stretches edge to edge.
- The tabs' `IndexedStack` has a `GlobalKey`. Folding or unfolding an iPhone Duo, rotating, or resizing a window
  switches between rail and tab bar without losing the open day, scroll position or chat.

### 2. Keyboard (`core/helpers/keyboard_shortcuts.dart`)
`commandShortcut` is ⌘ on iOS and macOS and Ctrl elsewhere.

| Keys | Where | Action |
|---|---|---|
| ⌘/Ctrl + 1…9 | anywhere in the tabs | open that tab |
| ⌘/Ctrl + N | anywhere in the tabs | open Today and the mind creator |
| ← / → | Today | previous / next day (a focused text field keeps its arrows) |
| ⌘/Ctrl + Enter | mind creator | save |
| Esc | mind creator, stories | close |

### 3. Mouse
The day feed tile menu is `super_context_menu`, which opens on a right click on iPad with a pointer and on desktop,
and on a long press on touch screens.

## Testing
- iPhone simulator: rotate to landscape (rail) and back (tab bar); an open sheet and the Today tab stay as they were.
- iPad or Android tablet with a hardware keyboard: try every shortcut in the table.
- There is no iPhone Duo simulator in Xcode 27.0 yet; the iPad mini in portrait (744 pt) is the closest check.

## Edge Cases & Considerations
- The Android activity is resizable by default (target SDK ≥ 24) and handles `screenSize|smallestScreenSize`
  config changes, so Googlebook windows resize without restarting the activity.
- Shortcuts live on a `Focus` in the tabs screen, so they don't fire inside pushed routes such as the mind creator,
  which has its own bindings.
