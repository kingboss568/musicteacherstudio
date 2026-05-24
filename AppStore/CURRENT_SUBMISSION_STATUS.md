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
- App Store Connect API key authentication is working with key `WZBYHD6QVD` and issuer `69a6de78-ba5a-47e3-e053-5b8c7c11a4d1`.
- `fastlane ios upload_metadata` completed successfully after uploading metadata, App Review information, age rating, and screenshots.
- Build `242245cb-0ab1-427c-a191-1aa4754d9d4a` is `VALID`, App Store eligible, and attached to iOS App version `1.0`.

## Verification Evidence

- IPA: `Build/Export/MusicTeacherStudio.ipa`
- IPA SHA-256: `55caee4787741f7f9208ef6a8c75ab0c48018cdf8bc113224bc1eba1fa2cec3f`
- dSYM: `Build/Export/MusicTeacherStudio.app.dSYM.zip`
- Screenshot sizes:
  - iPhone 6.9 inch: `1320x2868`
  - iPad 13 inch: `2064x2752`
- App Store Connect version:
  - App Store version id: `b9413198-40a8-4719-8466-7c17f07fc422`
  - State: `PREPARE_FOR_SUBMISSION`
  - Release type: manual
  - Attached build id: `242245cb-0ab1-427c-a191-1aa4754d9d4a`
  - Build processing state: `VALID`

## Blockers Before Actual Submission

1. IAPs must still be created or verified in App Store Connect and attached to app version `1.0`:
   `studio.pro.monthly`, `studio.pro.yearly`, `studio.pro.lifetime`.
   App Store Connect API currently reports `0` in-app purchases for this app.

2. App Store Connect version fields still require final UI verification in Comet before pressing Submit for Review:
   app privacy page, IAP attachment, and final review-submission readiness.

3. Review submission is not complete. Do not press Submit for Review until the IAP products exist and are included with the submission.

## Next Command Sequence After IAPs Are Ready

```sh
fastlane ios validate_submission_package
env -u APP_STORE_CONNECT_API_KEY_PATH \
  ASC_API_KEY_PATH=/Users/jushiung/Downloads/AuthKey_WZBYHD6QVD.p8 \
  APP_STORE_CONNECT_KEY_ID=WZBYHD6QVD \
  APP_STORE_CONNECT_ISSUER_ID=69a6de78-ba5a-47e3-e053-5b8c7c11a4d1 \
  fastlane ios submit_review
```
