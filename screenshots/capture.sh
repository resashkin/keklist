#!/bin/bash
# Captures raw English app screens with the demo data on a dedicated simulator.
#
#   ./screenshots/capture.sh iphone_69        # one device from screenshots/devices.json
#
# Writes screenshots/raw/<device>/<scene>.png. Then run compose.py for every language.
# The script owns its simulators ("keklist-shots …") and erases them on every run; it never touches others.
set -euo pipefail

DEVICE="${1:?usage: capture.sh <device id from devices.json>}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$(cd "$ROOT/.." && pwd)"
BUNDLE_ID="com.sashkyn.kekable"
WORK="$(mktemp -d -t keklist-shots)"
RAW="$ROOT/raw/$DEVICE"
LOG="$WORK/drive.log"
DEVICE_LOG="$WORK/device.log"

spec() { python3 -I -c "import json,sys; d=json.load(open('$ROOT/devices.json'))['$DEVICE']['capture']; print(d.get('$1',''))"; }
PLATFORM="$(spec platform)"
PENDING="$(spec pending)"
[[ -n "$PENDING" ]] && { echo "✗ $DEVICE can't be captured yet: $PENDING"; exit 1; }
[[ "$PLATFORM" == "ios" ]] || { echo "✗ $DEVICE: only iOS capture is implemented so far"; exit 1; }

SIM_TYPE="$(spec simulator)"
SIM_NAME="keklist-shots $SIM_TYPE"
UDID="$(xcrun simctl list devices -j | python3 -I -c "
import json, sys
for runtime, devices in json.load(sys.stdin)['devices'].items():
    for d in devices:
        if d['name'] == '$SIM_NAME' and d['isAvailable']: print(d['udid']); sys.exit()")"
if [[ -z "$UDID" ]]; then
  TYPE_ID="$(xcrun simctl list devicetypes -j | python3 -I -c "
import json, sys
print(next(t['identifier'] for t in json.load(sys.stdin)['devicetypes'] if t['name'] == '$SIM_TYPE'))")"
  RUNTIME_ID="$(xcrun simctl list runtimes -j | python3 -I -c "
import json, sys
rs = [r for r in json.load(sys.stdin)['runtimes'] if r['isAvailable'] and r['platform'] == 'iOS']
print(sorted(rs, key=lambda r: [int(x) for x in r['version'].split('.')])[-1]['identifier'])")"
  UDID="$(xcrun simctl create "$SIM_NAME" "$TYPE_ID" "$RUNTIME_ID")"
fi
echo "▶ $DEVICE on $SIM_NAME ($UDID)"

xcrun simctl shutdown "$UDID" >/dev/null 2>&1 || true
xcrun simctl erase "$UDID"
xcrun simctl boot "$UDID"
xcrun simctl bootstatus "$UDID" -b >/dev/null
xcrun simctl ui "$UDID" appearance light
xcrun simctl status_bar "$UDID" override --time "9:41" --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100

echo "▶ demo media"
python3 -I "$ROOT/prepare_media.py" "$WORK/media"
xcrun simctl addmedia "$UDID" "$WORK"/media/photos/*.jpg
xcrun simctl privacy "$UDID" grant photos "$BUNDLE_ID"

echo "▶ flutter drive (log: $LOG)"
# On iOS the test's print() goes to the device log, not to flutter drive's output.
xcrun simctl spawn "$UDID" log stream --style compact --predicate 'eventMessage CONTAINS "KEKLIST_"' >"$DEVICE_LOG" 2>&1 &
LOG_STREAM=$!
trap 'kill $LOG_STREAM 2>/dev/null || true' EXIT
mkdir -p "$RAW"
cd "$APP"
fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/store_screenshots_test.dart \
  -d "$UDID" --dart-define=KEKLIST_SCREENSHOTS=true >"$LOG" 2>&1 &
DRIVE=$!

MEDIA_COPIED=0
SEEN=0
while kill -0 "$DRIVE" 2>/dev/null; do
  if [[ $MEDIA_COPIED == 0 ]] && CONTAINER="$(xcrun simctl get_app_container "$UDID" "$BUNDLE_ID" data 2>/dev/null)"; then
    mkdir -p "$CONTAINER/Documents"
    cp -R "$WORK/media/user_files" "$CONTAINER/Documents/"
    xcrun simctl privacy "$UDID" grant photos "$BUNDLE_ID"
    MEDIA_COPIED=1
    echo "  media copied"
  fi
  SNAPS="$(grep -o 'KEKLIST_SNAP:[a-z_]*' "$DEVICE_LOG" || true)"
  COUNT="$(printf '%s' "$SNAPS" | grep -c . || true)"
  while (( SEEN < COUNT )); do
    SEEN=$((SEEN + 1))
    SCENE="$(printf '%s\n' "$SNAPS" | sed -n "${SEEN}p" | cut -d: -f2)"
    xcrun simctl io "$UDID" screenshot "$RAW/$SCENE.png" >/dev/null 2>&1
    echo "  📸 $SCENE"
  done
  sleep 0.3
done
wait "$DRIVE" || { tail -40 "$LOG"; echo "✗ flutter drive failed"; exit 1; }
xcrun simctl status_bar "$UDID" clear
echo "✓ $DEVICE: $SEEN screens in ${RAW#$APP/}"
