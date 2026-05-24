# Current Submission Status

Date: 2026-05-24

## Completed Locally

- App version is set to `1.0`.
- Bundle ID is `com.jiang.musicteacherstudio`.
- Team ID is configured as `7H7ZUG2WX8`.
- App icon was replaced with the supplied orange music notebook icon.
- In-app branding was updated on paywall and Settings, and the onboarding/paywall artwork now uses the new icon artwork.
- App Store metadata is staged in `fastlane/metadata/zh-Hant/`.
- Review contact is staged as Yu Shiung Jiang, +886952413678, jushiung@gmail.com.
- Privacy, Support, and Terms pages exist in repo under `docs/`.
- Public pages resolve:
  - `https://kingboss568.github.io/musicteacherstudio/privacy`
  - `https://kingboss568.github.io/musicteacherstudio/support`
  - `https://kingboss568.github.io/musicteacherstudio/terms`
- IAP product definitions are staged in `fastlane/iap_products.json` and `AppStore/IAP_PRODUCTS.md`.
- App Privacy answers are documented as `Data Not Collected`.
- App Review risk checklist is documented.
- iPhone 6.9-inch screenshots were captured to `fastlane/screenshots/zh-Hant/iphone69_*.png`.
- iPad 13-inch screenshots were captured to `fastlane/screenshots/zh-Hant/ipad13_*.png`.
- Screenshot copies were mirrored to `AppStore/Screenshots/`.
- `fastlane ios validate_metadata` passes.
- `fastlane ios validate_submission_package` passes.
- `fastlane ios capture_app_store_screenshots` passes and shuts down the dedicated simulators.
- `fastlane ios build_for_review` exports `Build/Export/MusicTeacherStudio.ipa`.
- Targeted screenshot route tests pass:
  `MusicTeacherStudioTests/ScreenshotLaunchRouteTests`, 3 tests, 0 failures.
- `fastlane ios submit_review` was attempted and stopped only after local validation passed, because App Store Connect authentication was missing.

## Verification Evidence

- IPA: `Build/Export/MusicTeacherStudio.ipa`
- IPA SHA-256: `55caee4787741f7f9208ef6a8c75ab0c48018cdf8bc113224bc1eba1fa2cec3f`
- dSYM: `Build/Export/MusicTeacherStudio.app.dSYM.zip`
- Screenshot sizes:
  - iPhone 6.9 inch: `1320x2868`
  - iPad 13 inch: `2064x2752`

## Blockers Before Actual Submission

1. App Store Connect authentication is not available in the shell environment:
   no `APP_STORE_CONNECT_API_KEY_PATH`, `APP_STORE_CONNECT_API_KEY`, or `FASTLANE_SESSION` was present during this run.

2. IAPs must still be created or verified in App Store Connect and attached to app version `1.0`:
   `studio.pro.monthly`, `studio.pro.yearly`, `studio.pro.lifetime`.

3. App Store Connect version fields still require final UI verification in Comet before pressing Submit for Review:
   category, age rating, app privacy page, build selection, IAP attachment, review information, and export compliance.

4. Binary upload and review submission are not complete until authenticated Fastlane or App Store Connect/Xcode upload confirms the build is processed and attached.

## Next Command Sequence After ASC Auth And IAPs Are Ready

```sh
fastlane ios validate_submission_package
fastlane ios upload_metadata
fastlane ios upload_build
fastlane ios submit_review
```
