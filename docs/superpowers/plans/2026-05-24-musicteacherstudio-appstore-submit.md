# MusicTeacherStudio App Store Submission Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prepare MusicTeacherStudio for App Store review with Fastlane metadata, IAP data, repo-hosted privacy/support pages, required screenshots, build evidence, and an honest submission boundary.

**Architecture:** Keep the iOS app offline-first and StoreKit-only. Put public pages under `docs/` for GitHub Pages, App Store metadata under `fastlane/metadata`, screenshots under `fastlane/screenshots`, and release automation in `fastlane/Fastfile`.

**Tech Stack:** SwiftUI, SwiftData, StoreKit 2, XCTest, XcodeBuild, Fastlane Deliver, GitHub Pages markdown.

---

### Task 1: Remove Review-Risky Claims

**Files:**
- Modify: `MusicTeacherStudio/Paywall/PaywallView.swift`
- Create: `MusicTeacherStudioTests/PaywallCopyTests.swift`

- [ ] **Step 1: Write the failing test**

```swift
import XCTest
@testable import MusicTeacherStudio

final class PaywallCopyTests: XCTestCase {
    func testFAQDoesNotPromiseUnimplementedCloudSync() {
        let combined = PaywallFAQ.all.map { "\($0.question) \($0.answer)" }.joined(separator: " ")
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("iCloud"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("雲端"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("自動跨裝置"))
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `xcodegen generate && xcodebuild -project MusicTeacherStudio.xcodeproj -scheme MusicTeacherStudio -destination 'generic/platform=iOS Simulator' -derivedDataPath Build/DerivedData CODE_SIGNING_ALLOWED=NO build-for-testing`

Expected before implementation: compile fails because `PaywallFAQ` does not exist.

- [ ] **Step 3: Implement minimal production change**

Move the FAQ copy into an internal `PaywallFAQ` type and replace the unimplemented iCloud sync claim with local export/restore wording.

- [ ] **Step 4: Verify build**

Run the same `build-for-testing` command. Expected: `TEST BUILD SUCCEEDED`.

### Task 2: Add Fastlane Submission Package

**Files:**
- Create: `fastlane/Appfile`
- Create: `fastlane/Deliverfile`
- Create: `fastlane/Fastfile`
- Create: `fastlane/metadata/zh-Hant/description.txt`
- Create: `fastlane/metadata/zh-Hant/keywords.txt`
- Create: `fastlane/metadata/zh-Hant/name.txt`
- Create: `fastlane/metadata/zh-Hant/privacy_url.txt`
- Create: `fastlane/metadata/zh-Hant/promotional_text.txt`
- Create: `fastlane/metadata/zh-Hant/release_notes.txt`
- Create: `fastlane/metadata/zh-Hant/subtitle.txt`
- Create: `fastlane/metadata/zh-Hant/support_url.txt`
- Create: `fastlane/metadata/zh-Hant/marketing_url.txt`
- Create: `fastlane/metadata/review_information/notes.txt`
- Create: `fastlane/iap_products.json`

- [ ] **Step 1: Add Fastlane config**

Use bundle id `com.jiang.musicteacherstudio`, Apple team name `Yu Shiung Jiang`, and GitHub Pages URLs:

```ruby
app_identifier("com.jiang.musicteacherstudio")
apple_id(ENV.fetch("FASTLANE_APPLE_ID", "jushiung@gmail.com"))
team_name("Yu Shiung Jiang")
```

- [ ] **Step 2: Add validation lane**

Add a `validate_submission_package` lane that fails if privacy/support pages, screenshot sets, metadata, or IAP JSON are missing.

- [ ] **Step 3: Add upload and submit lanes**

Add `upload_metadata`, `upload_build`, and `submit_review` lanes that use `deliver` and require App Store Connect credentials at runtime.

### Task 3: Publish Repo Pages

**Files:**
- Create: `docs/index.md`
- Create: `docs/privacy.md`
- Create: `docs/support.md`
- Create: `docs/terms.md`
- Modify: `PRIVACY.md`
- Modify: `SUPPORT.md`
- Modify: `TERMS.md`

- [ ] **Step 1: Add GitHub Pages documents**

Create lower-case `privacy`, `support`, and `terms` markdown pages matching the URLs already used by the app and metadata.

- [ ] **Step 2: Align policy statements**

Ensure every policy says the current version has no backend server, no third-party analytics, no tracking, and local template AI only.

### Task 4: Screenshot Readiness

**Files:**
- Create: `Scripts/capture_app_store_screenshots.sh`
- Modify: `AppStore/SCREENSHOTS.md`

- [ ] **Step 1: Add capture script**

Script must build the Debug app, boot `CBA-iPhone-6.9` and `GuoYueShot-iPad-13`, launch with `-MTSUsePreviewData -MTSForcePro`, save six distinct screenshots per device class, copy them into `fastlane/screenshots/zh-Hant`, and shut down the simulator it booted.

- [ ] **Step 2: Validate dimensions**

iPhone screenshots must be one of `1260x2736`, `1290x2796`, or `1320x2868`. iPad 13 screenshots must be `2064x2752` or `2048x2732`.

### Task 5: Release Verification And Submission Boundary

**Files:**
- Create: `AppStore/SUBMISSION_RUNBOOK.md`
- Create: `AppStore/REVIEW_RISK_CHECKLIST.md`

- [ ] **Step 1: Run verification**

Run build-for-testing, Fastlane validation, screenshot dimension validation, signing identity check, and Git status check.

- [ ] **Step 2: Upload only with credentials**

If `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` or App Store Connect API key credentials and an iOS Distribution signing identity are available, run Fastlane upload lanes. If not, stop with a precise blocker list instead of claiming submission readiness.
