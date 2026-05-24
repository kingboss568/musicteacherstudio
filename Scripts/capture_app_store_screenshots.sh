#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

APP_ID="com.jiang.musicteacherstudio"
APP_PATH="$ROOT_DIR/Build/DerivedData/Build/Products/Debug-iphonesimulator/MusicTeacherStudio.app"
OUTPUT_DIR="$ROOT_DIR/fastlane/screenshots/zh-Hant"
IPHONE_LEGACY_DIR="$ROOT_DIR/AppStore/Screenshots/iPhone-6.9"
IPAD_LEGACY_DIR="$ROOT_DIR/AppStore/Screenshots/iPad-13"

IOS_RUNTIME="${IOS_RUNTIME:-com.apple.CoreSimulator.SimRuntime.iOS-26-5}"
IPHONE_SIMULATOR_NAME="${IPHONE_SIMULATOR_NAME:-MTS-iPhone-6.9}"
IPAD_SIMULATOR_NAME="${IPAD_SIMULATOR_NAME:-MTS-iPad-13}"
IPHONE_DEVICE_TYPE="${IPHONE_DEVICE_TYPE:-com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max}"
IPAD_DEVICE_TYPE="${IPAD_DEVICE_TYPE:-com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M5-12GB}"

ACTIVE_UDIDS=()

cleanup() {
  for udid in "${ACTIVE_UDIDS[@]:-}"; do
    xcrun simctl terminate "$udid" "$APP_ID" >/dev/null 2>&1 || true
    xcrun simctl shutdown "$udid" >/dev/null 2>&1 || true
  done
  find "$OUTPUT_DIR" "$IPHONE_LEGACY_DIR" "$IPAD_LEGACY_DIR" -name '._*.png' -delete 2>/dev/null || true
}
trap cleanup EXIT

run_with_timeout() {
  local seconds="$1"
  shift
  local pid elapsed=0

  "$@" &
  pid="$!"

  while kill -0 "$pid" >/dev/null 2>&1; do
    if [[ "$elapsed" -ge "$seconds" ]]; then
      kill "$pid" >/dev/null 2>&1 || true
      wait "$pid" >/dev/null 2>&1 || true
      echo "Timed out after ${seconds}s: $*" >&2
      return 124
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done

  wait "$pid"
}

is_blank_image() {
  local file="$1"
  local stats ymin yavg ymax satavg satmax

  command -v ffmpeg >/dev/null 2>&1 || return 1
  stats="$(ffmpeg -hide_banner -i "$file" -vf "crop=iw:900:0:180,signalstats,metadata=print:file=-" -frames:v 1 -f null - 2>/dev/null || true)"
  ymin="$(printf '%s\n' "$stats" | awk -F= '/lavfi.signalstats.YMIN/ { print $2; exit }')"
  yavg="$(printf '%s\n' "$stats" | awk -F= '/lavfi.signalstats.YAVG/ { print $2; exit }')"
  ymax="$(printf '%s\n' "$stats" | awk -F= '/lavfi.signalstats.YMAX/ { print $2; exit }')"
  satavg="$(printf '%s\n' "$stats" | awk -F= '/lavfi.signalstats.SATAVG/ { print $2; exit }')"
  satmax="$(printf '%s\n' "$stats" | awk -F= '/lavfi.signalstats.SATMAX/ { print $2; exit }')"

  [[ -n "$ymin" && -n "$yavg" && -n "$ymax" && -n "$satavg" && -n "$satmax" ]] || return 1
  awk -v ymin="$ymin" -v y="$yavg" -v ymax="$ymax" -v s="$satavg" -v smax="$satmax" \
    'BEGIN { exit !(((ymax - ymin) < 3) && (s < 1) && (smax < 3) && (y > 220 || y < 35)) }'
}

capture_when_ready() {
  local udid="$1"
  local output="$2"
  local attempts=0

  while [[ $attempts -lt 12 ]]; do
    sleep 2
    rm -f "$output"
    xcrun simctl io "$udid" screenshot "$output"
    if ! is_blank_image "$output"; then
      return
    fi
    attempts=$((attempts + 1))
  done

  echo "Screenshot stayed blank after waiting: $output" >&2
  return 1
}

resolve_udid() {
  local name="$1"
  xcrun simctl list devices available |
    grep -F "$name" |
    sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/' |
    head -n 1
}

ensure_udid() {
  local name="$1"
  local device_type="$2"
  local udid
  udid="$(resolve_udid "$name")"
  if [[ -n "$udid" ]]; then
    echo "$udid"
    return
  fi

  xcrun simctl create "$name" "$device_type" "$IOS_RUNTIME"
}

wait_until_shutdown() {
  local udid="$1"
  local attempts=0
  while [[ $attempts -lt 30 ]]; do
    if xcrun simctl list devices available | grep -F "$udid" | grep -q "(Shutdown)"; then
      return
    fi
    sleep 1
    attempts=$((attempts + 1))
  done
}

wait_until_booted() {
  local udid="$1"
  run_with_timeout 120 xcrun simctl bootstatus "$udid" -b >/dev/null
  sleep 3
}

capture_device() {
  local prefix="$1"
  local simulator_name="$2"
  local legacy_dir="$3"
  local device_type="$4"
  local udid
  udid="$(ensure_udid "$simulator_name" "$device_type")"

  if [[ -z "$udid" ]]; then
    echo "Cannot find simulator named '$simulator_name'." >&2
    exit 1
  fi

  ACTIVE_UDIDS+=("$udid")

  xcrun simctl shutdown "$udid" >/dev/null 2>&1 || true
  wait_until_shutdown "$udid"
  xcrun simctl boot "$udid" >/dev/null 2>&1 || true
  wait_until_booted "$udid"
  xcrun simctl ui "$udid" appearance light >/dev/null 2>&1 || true
  run_with_timeout 120 xcrun simctl install "$udid" "$APP_PATH"

  local routes=(
    "dashboard:01_dashboard"
    "students:02_students"
    "lessons:03_lessons"
    "payments:04_payments"
    "settings:05_settings"
    "paywall:06_paywall"
  )

  mkdir -p "$OUTPUT_DIR" "$legacy_dir"

  for item in "${routes[@]}"; do
    local route="${item%%:*}"
    local slug="${item##*:}"
    local fastlane_file="$OUTPUT_DIR/${prefix}_${slug}.png"
    local legacy_file="$legacy_dir/${slug}.png"
    local tmp_file="/tmp/mts_${prefix}_${slug}_$$.png"

    xcrun simctl terminate "$udid" "$APP_ID" >/dev/null 2>&1 || true
    run_with_timeout 45 xcrun simctl launch "$udid" "$APP_ID" -MTSUsePreviewData -MTSForcePro -MTSScreenshotScreen "$route" >/dev/null
    capture_when_ready "$udid" "$tmp_file"
    cp "$tmp_file" "$fastlane_file"
    cp "$tmp_file" "$legacy_file"
    rm -f "$tmp_file"
  done

  xcrun simctl terminate "$udid" "$APP_ID" >/dev/null 2>&1 || true
  xcrun simctl shutdown "$udid" >/dev/null 2>&1 || true
}

xcodegen generate
xcodebuild \
  -project MusicTeacherStudio.xcodeproj \
  -scheme MusicTeacherStudio \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath Build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  ENABLE_DEBUG_DYLIB=NO \
  build

if [[ ! -d "$APP_PATH" ]]; then
  echo "Built app not found at $APP_PATH" >&2
  exit 1
fi

capture_device "iphone69" "$IPHONE_SIMULATOR_NAME" "$IPHONE_LEGACY_DIR" "$IPHONE_DEVICE_TYPE"
capture_device "ipad13" "$IPAD_SIMULATOR_NAME" "$IPAD_LEGACY_DIR" "$IPAD_DEVICE_TYPE"

find "$OUTPUT_DIR" "$IPHONE_LEGACY_DIR" "$IPAD_LEGACY_DIR" -name '._*.png' -delete

bash "$ROOT_DIR/Scripts/validate_app_store_package.sh"
