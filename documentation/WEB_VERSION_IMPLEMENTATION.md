# Web Version Implementation

## Overview
The phone app serves a copy of keklist built for the web, so the same interface opens in a browser on a computer in the same Wi‑Fi. The phone stays the only source of truth: the browser reads and writes the phone's Hive data through a small HTTP API and hears about changes through server-sent events. The pattern comes from the Herodotus project.

## Implementation Details

### 1. Phone side: the server (`lib/domain/services/web_server/`)
- `keklist_web_server.dart`: `KeklistWebServer` (a `ChangeNotifier`) binds `HttpServer` on `anyIPv4:port` while the app is open and restarts it on iOS resume. States: needs PIN, no bundle, starting, running (addresses), failed.
- `web_bundle.dart`: serves `assets/web/keklist_web.zip` straight from the zip, using the zip's deflate data as pre-gzipped bodies, with an ETag and `no-cache`.
- `web_access.dart`: the PIN is stored salted (HMAC-SHA256) in SharedPreferences. Sessions are stored as token digests and last 30 days. After 5 wrong PINs the login locks for 5 minutes. The default port is 8643.
- `login_page.dart`: the plain HTML PIN form. The session cookie `keklist_session` is httpOnly and SameSite=Strict.
- `bonjour_announcer.dart` (iOS, `ios/Runner/BonjourPlugin.swift`, channel `keklist/bonjour`) and `mdns_responder.dart` (Android, `keklist.local`): make the phone reachable by name as well as by IP.

Routes:

| Route | Meaning |
|---|---|
| `GET /login`, `POST /login` | PIN form |
| `GET /api/events` | SSE: `minds`, `emotions`, `profile`, plus a ping every 20 s |
| `GET/POST /api/minds`, `/api/emotions` | GET returns the list. POST takes `{"upsert": [...], "delete": [ids]}` |
| `GET/PUT /api/profile` | `{name, emoji, imagePath}`. PUT changes the name and/or emoji |
| `GET /files/<relative path>` | Audio, video, thumbnails and avatar, with Range support |
| `GET /api/gallery` | The phone's gallery index (see `GalleryWire`) |
| `GET /api/gallery/day?day=N` | A live listing of one day: the photo library on iOS, the media folder on Android |
| `GET /gallery/thumb?id=…`, `/gallery/full?id=…` | A 400px JPEG thumbnail; the original as a ~2048px JPEG (cached in the temp folder) or a video with Range |
| anything else | the web bundle, falling back to `index.html` |

Protections:
- The Host header must be an IP, `localhost` or `*.local` (against DNS rebinding).
- Writes must be `application/json` (against CSRF from plain forms).
- `/files` rejects path traversal.

`gallery_routes.dart` serves the gallery. Android folder items get opaque ids, and only ids that were listed to a browser can be fetched. An SSE `gallery` event goes out whenever the phone's index finishes a scan.

When a web edit or delete drops a mind's media, the server deletes those files, because the browser can't touch the phone's files.

### 2. Browser side: web mode (`lib/domain/services/phone_web/`)
- `phone_web_mode.dart`: `kIsPhoneWeb` is true only for builds made with `--dart-define=KEKLIST_WEB=phone`. The Telegram web build is unaffected.
- `phone_api.dart`: JSON over the page's own origin, so the cookie goes along. A 401 sends the page to the PIN form.
- `phone_collection.dart`: an in-memory mirror of a collection. Writes are optimistic, and it reloads on its SSE event and on every (re)connect.
- `MindApiRepository`, `EmotionApiRepository`, `PhoneSettingsRepository` and `WebFileRepository` are mapped in `lib/di/containers.dart` when `kIsPhoneWeb`.
- `PhoneSettingsRepository`: appearance, columns and tweaks stay in the browser's own Hive. Only the profile (name and avatar) comes from the phone. It reports emotions as seeded and onboarding as seen, so the browser never seeds the phone.
- `WebFileRepository`: media paths resolve to `/files/...` URLs, and it never creates files.
- `phone_gallery.dart`: the web `GalleryIndexer` gets a read-only mirror of the phone's index and a source that asks the phone for a day's media. So the calendar, day feed and stories show gallery media unchanged. `GalleryMedia` (`core/widgets/gallery/gallery_media.dart`) turns an asset into URLs on the web.

### 3. UI
- Settings → «Web version» (phone only, `widgets/web_version_rows.dart`): addresses with copy, PIN (set/remove) and port.
- At 800px and wider, the tabs become a `NavigationRail` on the left (`tabs_container_screen.dart`). Stories become a centered 9:16 card with ‹ › arrows; ←/→, space and Esc work too (`day_stories_screen.dart`).
- In the light theme, the emotion texture on mind tiles is half as strong and the tile text is semibold.
- `lib/presentation/core/helpers/media_sources.dart`: players and images take a URL when the path is remote (`videoControllerFor`, `setAudioSource`, `imageFor`). Waveforms are skipped for URLs.
- In web mode:
  - no audio/video recording and no profile photo picking;
  - no gallery or folder media in the day feed;
  - no export/import, danger zone or PRO row;
  - no paywall (membership is treated as pro);
  - no RevenueCat and no migrations.

### 4. Build
- `scripts/build_web_bundle.sh` builds the web app with `KEKLIST_WEB=phone` and zips it into `assets/web/keklist_web.zip`, which is gitignored and about 7 MB. The asset is declared for Android and iOS only.
- `ios/fastlane/Fastfile` runs the script before every iOS build. Without the zip the server reports "no bundle".

## How It Works
1. The user sets a PIN in Settings, and the server starts and shows its addresses.
2. The computer opens `http://<phone>.local:8643`, enters the PIN and gets the cookie.
3. The web app loads minds and emotions from `/api/...` and listens on `/api/events`.
4. Changes on either side are written to the phone's Hive, which notifies every open browser.

## Testing
- `test/domain/services/phone_web/phone_collection_test.dart`: load, reload on events, optimistic upsert/delete, and 401 → PIN form.
- Manual test:
  1. Run `./scripts/build_web_bundle.sh`.
  2. Run the app on a simulator and set a PIN.
  3. Open `http://localhost:8643`.
  4. Create a mind on each side and watch it appear on the other.

## Edge Cases & Considerations
- The server lives only while the app is in the foreground. There is no Android foreground service.
- iOS asks for Local Network access the first time (`NSLocalNetworkUsageDescription`, `NSBonjourServices`).
- Removing the PIN stops the server, and changing the PIN invalidates every session.
- `archive` stays on 4.0.x: 4.5 breaks the export/import ZIP round-trip tests.
