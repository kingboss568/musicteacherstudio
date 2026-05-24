# Submission Runbook

Use Comet for App Store Connect browser operations.

## 1. Local Validation

```sh
fastlane ios validate_metadata
xcodegen generate
xcodebuild -project MusicTeacherStudio.xcodeproj -scheme MusicTeacherStudio -destination 'generic/platform=iOS Simulator' -derivedDataPath Build/DerivedData CODE_SIGNING_ALLOWED=NO build-for-testing
```

## 2. Screenshots

```sh
fastlane ios capture_app_store_screenshots
fastlane ios validate_submission_package
```

Required output:

- `fastlane/screenshots/zh-Hant/iphone69_01_dashboard.png` through `iphone69_06_paywall.png`
- `fastlane/screenshots/zh-Hant/ipad13_01_dashboard.png` through `ipad13_06_paywall.png`

Each capture process shuts down the simulator it started.

## 3. App Store Connect Setup

Use these fixed values unless the owner changes them:

| Field | Value |
|---|---|
| Team | Yu Shiung Jiang |
| Team ID | 7H7ZUG2WX8 |
| Contact | Yu Shiung Jiang |
| Phone | +886952413678 |
| Email | jushiung@gmail.com |
| Support URL | https://kingboss568.github.io/musicteacherstudio/support |
| Privacy URL | https://kingboss568.github.io/musicteacherstudio/privacy |

Create the three IAP products listed in `AppStore/IAP_PRODUCTS.md` and attach them to version `1.0`.

## 4. Build IPA

Requires a valid signing setup for `com.jiang.musicteacherstudio`.
This repo is configured for automatic signing with Team ID `7H7ZUG2WX8`; archive still requires App Store Connect access to create/download the App Store provisioning profile if it is not already installed locally.

```sh
fastlane ios build_for_review
```

Expected IPA:

```text
Build/Export/MusicTeacherStudio.ipa
```

## 5. Upload And Submit

Requires App Store Connect authentication through `APP_STORE_CONNECT_API_KEY_PATH`, `APP_STORE_CONNECT_API_KEY`, or `FASTLANE_SESSION`.

```sh
fastlane ios upload_metadata
fastlane ios upload_build
fastlane ios submit_review
```

Do not report "ready for review" until Support and Privacy pages are pushed to GitHub and the GitHub Pages URLs resolve publicly.
