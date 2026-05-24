#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ALLOW_MISSING_SCREENSHOTS=false
if [[ "${1:-}" == "--allow-missing-screenshots" ]]; then
  ALLOW_MISSING_SCREENSHOTS=true
fi

failures=()

fail() {
  failures+=("$1")
}

require_file() {
  local file="$1"
  [[ -s "$file" ]] || fail "Missing or empty file: $file"
}

require_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"
  if [[ -s "$file" ]]; then
    grep -qF "$needle" "$file" || fail "$label"
  else
    fail "Cannot inspect missing file: $file"
  fi
}

pixel_size() {
  local file="$1"
  sips -g pixelWidth -g pixelHeight "$file" 2>/dev/null |
    awk '/pixelWidth/ { width=$2 } /pixelHeight/ { height=$2 } END { print width "x" height }'
}

is_iphone_69_size() {
  case "$1" in
    1260x2736|1290x2796|1320x2868) return 0 ;;
    *) return 1 ;;
  esac
}

is_ipad_13_size() {
  case "$1" in
    2064x2752|2048x2732) return 0 ;;
    *) return 1 ;;
  esac
}

required_files=(
  ".gitignore"
  "project.yml"
  "PRIVACY.md"
  "SUPPORT.md"
  "TERMS.md"
  "docs/index.md"
  "docs/privacy.md"
  "docs/support.md"
  "docs/terms.md"
  "APP_STORE_LISTING.md"
  "AppStore/REVIEW_NOTES.md"
  "AppStore/SCREENSHOTS.md"
  "AppStore/IAP_PRODUCTS.md"
  "AppStore/APP_PRIVACY_DETAILS.md"
  "AppStore/REVIEW_RISK_CHECKLIST.md"
  "AppStore/SUBMISSION_RUNBOOK.md"
  "fastlane/Appfile"
  "fastlane/Deliverfile"
  "fastlane/Fastfile"
  "fastlane/app_rating_config.json"
  "fastlane/iap_products.json"
  "fastlane/metadata/zh-Hant/name.txt"
  "fastlane/metadata/zh-Hant/subtitle.txt"
  "fastlane/metadata/zh-Hant/description.txt"
  "fastlane/metadata/zh-Hant/keywords.txt"
  "fastlane/metadata/zh-Hant/release_notes.txt"
  "fastlane/metadata/zh-Hant/privacy_url.txt"
  "fastlane/metadata/zh-Hant/support_url.txt"
  "fastlane/metadata/review_information/notes.txt"
)

for file in "${required_files[@]}"; do
  require_file "$file"
done

require_contains "project.yml" 'MARKETING_VERSION: "1.0"' "project.yml must use App Store version 1.0"
require_contains "project.yml" "PRODUCT_BUNDLE_IDENTIFIER: com.jiang.musicteacherstudio" "Bundle identifier mismatch"
require_contains "MusicTeacherStudio/Resources/Info.plist" "ITSAppUsesNonExemptEncryption" "Info.plist must include encryption declaration"

for product_id in studio.pro.monthly studio.pro.yearly studio.pro.lifetime; do
  require_contains "MusicTeacherStudio/Resources/Configuration.storekit" "$product_id" "StoreKit config missing $product_id"
  require_contains "fastlane/iap_products.json" "$product_id" "Fastlane IAP package missing $product_id"
  require_contains "AppStore/IAP_PRODUCTS.md" "$product_id" "IAP runbook missing $product_id"
done

for url in \
  "https://kingboss568.github.io/musicteacherstudio/privacy" \
  "https://kingboss568.github.io/musicteacherstudio/support" \
  "https://kingboss568.github.io/musicteacherstudio/terms"; do
  require_contains "APP_STORE_LISTING.md" "$url" "Listing missing $url"
  require_contains "AppStore/REVIEW_NOTES.md" "$url" "Review notes missing $url"
done

if grep -RInE 'iCloud|雲端同步|自動跨裝置' \
  APP_STORE_LISTING.md AppStore/REVIEW_NOTES.md fastlane/metadata docs/index.md docs/privacy.md docs/support.md docs/terms.md MusicTeacherStudio/Paywall 2>/dev/null; then
  fail "Found unimplemented cloud-sync wording in review-facing copy"
fi

if git ls-files | grep -qE '(^|/)\._|(^|/)__MACOSX/|(^|/)\.AppleDouble/'; then
  fail "AppleDouble or macOS resource fork files are tracked by git"
fi

if ! $ALLOW_MISSING_SCREENSHOTS; then
  iphone_files=(fastlane/screenshots/zh-Hant/iphone69_*.png)
  ipad_files=(fastlane/screenshots/zh-Hant/ipad13_*.png)

  if [[ ! -e "${iphone_files[0]}" ]]; then
    fail "Missing iPhone 6.9-inch Fastlane screenshots"
  elif [[ ${#iphone_files[@]} -lt 6 ]]; then
    fail "Need at least 6 iPhone 6.9-inch screenshots, found ${#iphone_files[@]}"
  else
    for file in "${iphone_files[@]}"; do
      size="$(pixel_size "$file")"
      is_iphone_69_size "$size" || fail "Invalid iPhone 6.9 screenshot size $size: $file"
    done
  fi

  if [[ ! -e "${ipad_files[0]}" ]]; then
    fail "Missing iPad 13-inch Fastlane screenshots"
  elif [[ ${#ipad_files[@]} -lt 6 ]]; then
    fail "Need at least 6 iPad 13-inch screenshots, found ${#ipad_files[@]}"
  else
    for file in "${ipad_files[@]}"; do
      size="$(pixel_size "$file")"
      is_ipad_13_size "$size" || fail "Invalid iPad 13 screenshot size $size: $file"
    done
  fi
fi

if [[ ${#failures[@]} -gt 0 ]]; then
  printf 'App Store package validation failed:\n' >&2
  for item in "${failures[@]}"; do
    printf -- '- %s\n' "$item" >&2
  done
  exit 1
fi

echo "App Store package validation passed."
