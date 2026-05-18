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
```

This uses an in-memory SwiftData container seeded with demo students, lessons, assignments, payments, and recordings. It also skips onboarding so App Store screenshots show real product screens instead of empty data.

## Recommended Captures

1. Dashboard: 30 秒記錄與今日工作台
2. Students: 學生、欠款與最近課程
3. Lesson note: 出席與課堂筆記 30 秒流程
4. Payment tracker: 欠款追蹤
5. AI draft: 家長訊息與學習摘要
6. Paywall: Pro 工作室價值

## Captured In This Repo

`AppStore/Screenshots/iPhone-6.9/` currently contains five direct simulator screenshots at 1320×2868.

The iPad 13-inch simulator booted intermittently in this environment, but app installation failed with CoreSimulator Mach errors while other simulator install processes were also running. Capture iPad 13-inch again from a clean Simulator state before final App Review upload.
