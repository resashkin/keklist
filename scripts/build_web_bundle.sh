#!/bin/sh
# Builds the web version that talks to the phone and packs it into assets/web/keklist_web.zip, which the iOS and
# Android apps serve to browsers in the local network. Run it before building the phone apps; fastlane does.
set -eu
cd "$(dirname "$0")/.."

fvm flutter build web --release --dart-define=KEKLIST_WEB=phone --no-web-resources-cdn \
  --no-source-maps --no-wasm-dry-run --suppress-analytics

out="$PWD/assets/web/keklist_web.zip"
mkdir -p assets/web
rm -f "$out"
cd build/web
# Browsers get no secrets: the phone keeps the API keys and tokens, the web version only reads its data.
printf '# The web version keeps no keys.\n' > assets/dotenv
# The dart2js build loads canvaskit/ (or canvaskit/chromium/); the other engine builds are never requested.
zip -q -r -9 "$out" . \
  -x 'canvaskit/skwasm*' 'canvaskit/wimp*' 'canvaskit/webparagraph/*' \
  -x '*.symbols' '*.map' '_test/*' 'firebase-debug.log' 'auth.html'
echo "Packed $(du -h "$out" | cut -f1) into $out"
