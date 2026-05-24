# Screenshot Checklist

Official Apple screenshot specifications:

https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications

## Required Sets For This Universal App

| Device class | Accepted portrait sizes |
|---|---|
| iPhone 6.9 inch | 1260×2736, 1290×2796, or 1320×2868 |
| iPad 13 inch | 2064×2752 or 2048×2732 |

## Debug Screenshot Launch Args

Use the `Debug` build with:

```text
-MTSUsePreviewData
-MTSForcePro
-MTSScreenshotScreen dashboard|students|lessons|payments|settings|paywall
```

This uses an in-memory SwiftData container seeded with demo students, lessons, assignments, payments, and recordings. It also skips onboarding so App Store screenshots show real product screens instead of empty data.

## Recommended Captures

1. Dashboard: 30 秒記錄與今日工作台
2. Students: 學生、欠款與最近課程
3. Lesson note: 出席與課堂筆記 30 秒流程
4. Payment tracker: 欠款追蹤
5. AI draft: 家長訊息與學習摘要
6. Paywall: Pro 工作室價值

## Fastlane Capture

Run:

```sh
fastlane ios capture_app_store_screenshots
```

The script captures six iPhone 6.9-inch screenshots and six iPad 13-inch screenshots into `fastlane/screenshots/zh-Hant/`, mirrors them into `AppStore/Screenshots/`, validates their dimensions, and shuts down each simulator after its capture pass.

By default it creates and uses dedicated simulators named `MTS-iPhone-6.9` and `MTS-iPad-13` so other background screenshot jobs do not collide with this app. Override with `IPHONE_SIMULATOR_NAME` or `IPAD_SIMULATOR_NAME` only when deliberately reusing an existing simulator.

## Captured In This Repo

Fastlane-ready output must include:

- `fastlane/screenshots/zh-Hant/iphone69_01_dashboard.png` through `iphone69_06_paywall.png`
- `fastlane/screenshots/zh-Hant/ipad13_01_dashboard.png` through `ipad13_06_paywall.png`

Run `Scripts/validate_app_store_package.sh` before upload; it fails if either required device class is missing or has an invalid pixel size.
