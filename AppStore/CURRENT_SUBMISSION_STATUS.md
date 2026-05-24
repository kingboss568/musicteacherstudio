# Current Submission Status

Date: 2026-05-24

## Completed

- App version is set to `1.0`.
- Bundle ID is `com.jiang.musicteacherstudio`.
- Team ID is configured as `7H7ZUG2WX8`.
- App Store metadata is staged in `fastlane/metadata/zh-Hant/`.
- Review contact is staged as Yu Shiung Jiang, +886952413678, jushiung@gmail.com.
- Privacy, Support, and Terms pages exist in repo under `docs/`.
- IAP product definitions are staged in `fastlane/iap_products.json` and `AppStore/IAP_PRODUCTS.md`.
- App Privacy answers are documented as `Data Not Collected`.
- App Review risk checklist is documented.
- `fastlane ios validate_metadata` passes.
- `xcodebuild ... build-for-testing` passes.
- `fastlane ios build_for_review` successfully creates an archive before export.

## Blockers Before Actual Submission

1. App Store provisioning profile missing:
   `fastlane ios build_for_review` fails during export with `No profiles for 'com.jiang.musicteacherstudio' were found`.

2. App Store Connect authentication is not available in the shell environment:
   no `APP_STORE_CONNECT_API_KEY_PATH`, `APP_STORE_CONNECT_API_KEY`, or `FASTLANE_SESSION` was present during this run.

3. Screenshots are not complete:
   CoreSimulator `simctl install` entered a hung state while multiple unrelated background simulator jobs were also installing/launching apps. The repo now contains a dedicated `fastlane ios capture_app_store_screenshots` lane, but the final iPhone 6.9-inch and iPad 13-inch screenshot set still needs a clean simulator run.

4. IAPs must still be created/verified in App Store Connect and attached to app version `1.0`:
   `studio.pro.monthly`, `studio.pro.yearly`, `studio.pro.lifetime`.

5. Support and Privacy pages must be pushed to GitHub and publicly resolving before reporting review-ready.

## Next Command Sequence After Blockers Are Resolved

```sh
fastlane ios capture_app_store_screenshots
fastlane ios validate_submission_package
fastlane ios build_for_review
fastlane ios upload_metadata
fastlane ios upload_build
fastlane ios submit_review
```
