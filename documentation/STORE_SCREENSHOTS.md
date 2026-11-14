# Store Screenshots Implementation

## Overview
Store screenshots are made by scripts in two steps, so captions can be fixed in seconds without touching a
simulator:

1. **Capture (slow, rare).** The app runs on a dedicated simulator with demo data and English UI; a test walks the
   scenes and the script saves raw screens to `screenshots/raw/<device>/<scene>.png`.
2. **Compose (seconds).** `compose.py` draws a device frame around each raw screen and puts the caption from
   `screenshots/strings/<lang>.yaml` above it, at the store's exact pixel size.

The app UI is English in every language; only captions are translated.

## Usage
```bash
./screenshots/capture.sh iphone_69          # raw screens for one device
python3 screenshots/compose.py en           # every captured device, English captions
python3 screenshots/compose.py ru iphone_69 # one device, Russian captions
```
Output: `screenshots/out/<lang>/<device>/NN_<scene>.png`. `raw/`, `out/` and the downloaded photos are gitignored.

## Implementation Details
### Files
- `screenshots/devices.json`: devices, output sizes, frame style and how each is captured.
- `screenshots/strings/<lang>.yaml`: `scene: caption`, one per line, in screenshot order.
- `screenshots/prepare_media.py`: downloads the Unsplash demo photos (Unsplash License) on first use, stamps each
  with an EXIF date so it lands on its demo day, and makes the voice note (`say`) and the round video (ffmpeg).
- `screenshots/capture.sh`: creates or erases its own simulator `keklist-shots <model>`, sets 9:41 in the status
  bar and dark appearance, adds the photos, runs `flutter drive`, copies the voice note and video into the app's
  documents, and takes a screenshot whenever the test logs `KEKLIST_SNAP:<scene>`.
- `screenshots/compose.py`: HTML page per screen rendered by headless Chrome; no Python packages needed.
- `lib/domain/services/screenshots/screenshot_demo.dart`: with `--dart-define=KEKLIST_SCREENSHOTS=true` the app
  replaces all data with the demo set on start: minds over the last three weeks, an emotion tree, the profile
  "Alex", analytics off, What's New, review prompt and shake hints marked as seen.
- `integration_test/store_screenshots_test.dart` + `test_driver/integration_test.dart`: the scene walk.

### Scenes
| Scene | What the test shows |
|---|---|
| day | Today: notes and today's photos |
| emotions | the emotion sheet over Today |
| insights | the Profile (insights) tab |
| voice | yesterday: a voice note and a round video |
| gallery | the trip day, three days ago, with 8 photos |
| calendar | the calendar scrolled to the past days |
| web | not captured yet; needs a browser screenshot of the web version |
| privacy | Settings |

### Captions
`**word**` puts a white highlighter mark (purple text) on the purple brand background on that word; each caption marks the search keyword of its
screen. The marks live in the string files, so translators keep them.

A caption must fit two lines at the fixed font size. If it doesn't, `compose.py` prints an error and skips that
screen instead of shrinking the text.

## Edge Cases & Considerations
- `capture.sh` erases only simulators it created (named `keklist-shots …`).
- iOS prints from the test go to the device log, so the script reads markers with `log stream`.
- iPhone Duo has no simulator in Xcode 27.0; its entries in `devices.json` are marked `pending`.
- Android, Android tablet and Googlebook capture are listed in `devices.json` but not implemented yet.
- The demo data replaces all data, so it only runs in debug builds (`kDebugMode`); release builds ignore the flag.
