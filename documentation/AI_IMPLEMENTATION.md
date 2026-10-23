# AI Implementation

## Overview
The AI tab lets the user talk about their records with a language model that runs on the phone. It also writes short summaries of days. There is nothing online about the model: records, sessions and generation never leave the device. The network is used only to download models and the model lists.

- **Tab:** the AI tab sits before Settings. Existing users get it inserted there once.
- **Top of the tab:** cards with day summaries.
- **Below:** previous sessions. A tap opens the chat; a swipe deletes a session.
- **New session:** starts with a role, which stays for the whole session. The built-in roles are therapist (reflective, CBT/ACT style, never diagnoses), coach and friend; users can add their own roles.
- **Chips** under the last reply:
  - 2–3 replies suggested by the model;
  - "Save as mind" (the reply goes to today);
  - "Open day" (the day the reply was based on);
  - "Week summary".
- **Free:** the feature is not part of PRO.

## Implementation Details

### 1. Engines (`lib/domain/services/ai/ai_engine.dart`)
- **One package:** [llamadart](https://pub.dev/packages/llamadart) runs GGUF models through llama.cpp and `.litertlm` models through LiteRT-LM behind one API (`LlamaEngine`). Both runtimes ship with the app.
- **Apple linking:** Apple builds link them through the SwiftPM companions `llamadart_llama_cpp_flutter` and `llamadart_litert_lm_flutter`, whose frameworks carry their privacy manifests.
- **One at a time:** one model is in memory and one generation runs; requests queue. Cancelling a reply, whether running or still queued, frees the queue right away.
- **Loading:** the model loads on first use. If the GPU path is unsupported, loading retries on the CPU. Thinking is off.
- **Platform requirements:**
  - iOS deployment target 16.4.
  - The Intel simulator is excluded in `ios/Flutter/{Debug,Release}.xcconfig`, because LiteRT-LM has no x86_64 simulator build.

### 2. Models
- **Catalog** (`ai_catalog.dart`):
  - **Google AI Edge Gallery:** the newest Android (`N_N_N.json`) and iOS (`ios_*.json`) lists from `google-ai-edge/gallery/model_allowlists`. They are merged, keeping `llm_chat` `.litertlm` models, sorted by size. The smallest is labelled "Fastest". New models appear when Google adds them to the list.
  - **Hugging Face GGUF search:** `gated=false`, sorted by downloads. With nothing typed, it shows popular repositories of 0.5–4B models.
  - **Repository files:** opening a repository lists its `.gguf` files without `mmproj`, pinned to the repository's revision. Only files up to 55% of the phone's memory are shown.
  - **Open models only:** gated repositories need a Hugging Face login, so they are left out. A Gallery entry is dropped when the phone has less memory than its `minDeviceMemoryInGb`.
- **Device memory** (`device_memory.dart`): `sysctl hw.memsize` on iOS and `/proc/meminfo` on Android. The web version gets a stub.
- **Downloads and storage** (`ai_model_store.dart`):
  - Downloads go through `background_downloader` (group `ai_models`). It uses URLSession / WorkManager, so downloads continue in the background, can pause and resume, and are restored on launch.
  - Before a download on mobile data, the user is asked (`connectivity_plus`).
  - Files go to `Application Support/ai_models`. Several can be kept, and one is active.

### 3. Storage (`ai_storage.dart`)
Encrypted Hive boxes (the app's AES cipher) hold JSON strings:

| Box | Contents |
|---|---|
| `ai_sessions_box` | `AiSession` with its messages, suggestions and the days each reply used |
| `ai_personas_box` | the user's own roles |
| `ai_day_summaries_box` | `AiDaySummary` with a hash of the day's records |
| `ai_models_box` | downloaded models, the active one, the last Gallery list |

None of this goes into the ZIP export.

### 4. Context (`ai_context_builder.dart`)
Every message gets, within about 6000 characters:
1. The latest 3 days with records, in full: time, emotions and text, with reflections under their record.
2. Up to 6 more days that match the message:
   - by words: word beginnings, so Russian endings still match;
   - by dates: "yesterday", "позавчера", `dd.mm`, "N days ago";
   - by emotions: an emoji or title.
3. Summaries of other days, newest first, while the budget allows.

History takes the last 12 messages, up to about 4000 characters.

### 5. Prompts (`ai_prompts.dart`)
- **Prompts:** role prompts are in English, which small models follow best. Replies come in the app's language (`AiFormat.languageOf`).
- **Shared rules:**
  - use only the given records;
  - don't claim to be a doctor;
  - if the user may be in danger, urge contacting emergency services or a crisis line and someone they trust;
  - end with a `>> a | b | c` line, which becomes chips and is hidden while the reply streams.
- **Read-only built-ins:** the built-in roles can't be edited, only duplicated.

### 6. Backends (`ai_backend.dart`)
- `LocalAiBackend` (the phone):
  - runs the model;
  - writes sessions and summaries;
  - streams the reply every 120 ms.
- **Summaries:** a summary is written when its card is tapped. While the tab is open and the phone is charging (`battery_plus`), up to 7 missing or outdated summaries are written one by one per visit, and a chat message stops them. A summary is outdated when the hash of its day's records changes, or when `AiPrompts.daySummaryVersion` is bumped after a prompt change.
- `PhoneAiBackend` (the web version served by the phone): models are managed on the phone. The browser calls these routes:

| Route | Meaning |
|---|---|
| `GET /api/ai` | the whole state (`AiBackend.stateJson`) |
| `POST /api/ai/session` `{personaId}` | new session → `{id}` |
| `POST /api/ai/session/delete` `{id}` | delete a session |
| `POST /api/ai/send` `{sessionId, text}` | the phone answers in the background |
| `POST /api/ai/stop` | stop the reply |
| `POST /api/ai/summarize` `{day}` | write a day's summary |
| SSE `ai` | the state changed: reload |
| SSE `ai-reply` | the reply being written, `{sessionId, text}` or `null` |

### 7. UI (`lib/presentation/screens/ai/`)
- `ai_screen.dart`:
  - The tab itself.
  - On the first visit without a model, it opens the catalog once.
  - It turns background summaries on while it is the selected tab.
- `ai_chat_screen.dart`:
  - Bubbles, the streaming reply and chips.
  - Enter sends on a desktop, Shift+Enter makes a new line.
- `ai_models_screen.dart`, `ai_hf_search_screen.dart`: downloaded models, downloads, the Gallery list and the Hugging Face search.
- `ai_personas_screen.dart`: roles and the role editor.
- Settings → AI: Models and Roles (phone only).

## Updated Files
- **New:**
  - `lib/domain/services/ai/*`;
  - `lib/domain/services/phone_web/phone_ai_backend.dart`, `lib/domain/services/web_server/ai_routes.dart`;
  - `lib/presentation/screens/ai/*`.
- **Changed:**
  - `main.dart` (creating the AI);
  - `di/containers.dart` (`PhoneApi` in DI);
  - `keklist_web_server.dart` (routes, SSE with data);
  - `browser_bridge*.dart` (event data, `gallery` and `ai` events);
  - `tabs_settings.dart` (`TabType.ai`);
  - `constants.dart` (default tabs);
  - `tabs_settings_shared_preferences_repository.dart` (inserting the tab once);
  - `tabs_container_screen.dart`, `settings_screen.dart`, `settings_layout.dart`;
  - all 12 ARB files.
- **Platform:** `pubspec.yaml`, `ios/Runner.xcodeproj` (16.4), `ios/Flutter/*.xcconfig`.
- **Export:** `export_import_service.dart`. ZIP entry sizes are now in bytes, because llamadart needs archive 4.5, which stops at an entry's size. Older exports with emoji or Cyrillic text still import, since their CSV sizes are allowed up to 4×.

## Testing
- `test/domain/services/ai/`:
  - suggestion parsing;
  - context selection (recent, by words, emotions, dates, budget, reflections);
  - Gallery merging and gating;
  - GGUF file listing.
- `test/domain/services/export_import/emotion_round_trip_test.dart`: an export made before archive 4.5 imports whole.
- **Manual:**
  1. Run on a simulator and open the AI tab.
  2. In the Hugging Face search, download Qwen2.5-0.5B-Instruct `q4_k_m` (469 MB).
  3. Start a Therapist session, send a message and check the streaming reply and chips.
  4. Tap a day card and check its summary.

## Edge Cases & Considerations
- **Simulator speed:** the simulator runs models on the CPU and is slow. Judge speed on a device.
- **Memory:** Gallery models need 6–12 GB of RAM per Google's list; 0.5–1.5B GGUF files fit older phones.
- **Telegram web:** the Telegram web build has no AI tab.
- **Deleting a model:** deleting or switching the active model unloads it from memory.
