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
}
trap cleanup EXIT

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

wait_until_booted() {
  local udid="$1"
  local attempts=0
  while [[ $attempts -lt 60 ]]; do
    if xcrun simctl list devices available | grep -F "$udid" | grep -q "(Booted)"; then
      sleep 5
      return
    fi
    sleep 2
    attempts=$((attempts + 1))
  done

  echo "Simulator $udid did not reach Booted state." >&2
  exit 1
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
  xcrun simctl boot "$udid" >/dev/null 2>&1 || true
  wait_until_booted "$udid"
  xcrun simctl ui "$udid" appearance light >/dev/null 2>&1 || true
  xcrun simctl install "$udid" "$APP_PATH"

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
    xcrun simctl launch "$udid" "$APP_ID" -MTSUsePreviewData -MTSForcePro -MTSScreenshotScreen "$route" >/dev/null
    sleep 4
    rm -f "$tmp_file"
    xcrun simctl io "$udid" screenshot "$tmp_file"
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
  build

if [[ ! -d "$APP_PATH" ]]; then
  echo "Built app not found at $APP_PATH" >&2
  exit 1
fi

capture_device "iphone69" "$IPHONE_SIMULATOR_NAME" "$IPHONE_LEGACY_DIR" "$IPHONE_DEVICE_TYPE"
capture_device "ipad13" "$IPAD_SIMULATOR_NAME" "$IPAD_LEGACY_DIR" "$IPAD_DEVICE_TYPE"

bash "$ROOT_DIR/Scripts/validate_app_store_package.sh"
