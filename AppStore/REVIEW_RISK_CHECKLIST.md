# App Review Risk Checklist

This checklist targets the rejection loops most likely for this app.

## Metadata Accuracy

- Do not claim iCloud sync, cloud sync, automatic cross-device sync, push notifications, or external AI service integration.
- Paid features must be described as Pro/IAP gated in description and screenshots.
- Screenshots must show real in-app screens, not only title art.
- Demo data in screenshots must be fictional.

## IAP

- All digital unlocks use StoreKit.
- The submitted app version must include `studio.pro.monthly`, `studio.pro.yearly`, and `studio.pro.lifetime`.
- Restore purchases must remain visible and functional.
- App Review notes must explain that no login is required.

## Privacy

- App Store privacy answers must stay consistent with `PRIVACY.md` and `docs/privacy.md`.
- If any analytics, backend, login, cloud sync, or external AI call is added later, App Privacy and privacy policy must be updated before upload.

## Technical Quality

- `xcodegen generate` must be run before archive.
- `xcodebuild ... build-for-testing` must pass before capture or archive.
- iPhone 6.9-inch and iPad 13-inch screenshot sets must both exist and pass dimension validation.
- Archive/export requires a valid Apple Distribution certificate and App Store provisioning profile for `com.jiang.musicteacherstudio`.

## Current Guardrails

- `MusicTeacherStudioTests/PaywallCopyTests.swift` blocks unimplemented cloud-sync wording in the paywall FAQ.
- `MusicTeacherStudioTests/ScreenshotLaunchRouteTests.swift` protects screenshot launch routing.
- `Scripts/validate_app_store_package.sh` validates required metadata, URLs, IAP IDs, Git hygiene, and screenshot dimensions.
