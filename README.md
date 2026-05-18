# MusicTeacherStudio

私人音樂老師管理 App（iOS / iPadOS、SwiftUI + SwiftData、離線優先）。

## 開啟專案

```bash
open MusicTeacherStudio.xcodeproj
```

如果 `.xcodeproj` 遺失或修改了 `project.yml`，請重新產生：

```bash
xcodegen generate
```

## 建置 / 測試

```bash
xcodebuild -scheme MusicTeacherStudio \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

xcodebuild -scheme MusicTeacherStudio \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## MVP 範圍（本版本）

完成：
- 學生 CRUD
- 課程 CRUD（單次課 / 固定課表模板 / 4 週批次產生 / 重複時段跳過）
- 出席狀態與課堂筆記（30 秒流程）
- 收費 / 付款紀錄 / 欠款計算
- 作業 CRUD
- 老師手動匯入錄音（複製至 sandbox `Documents/Recordings/`）
- 學生學習歷程 PDF 匯出（`Documents/Reports/`，預設不含付款資訊）
- 全部資料離線可用
- Preview seed data
- **AI 草稿層（離線 Mock）**：
  - `AIProvider` protocol + `MockAIProvider`（無網路、無 API Key）
  - `ParentMessageDraftAI`（簡短/標準/鼓勵 3 版本）
  - `LessonSummaryAI`（最近練習重點 / 進展 / 仍需穩定 / 下週建議 / 家長簡短版）
  - `AIPromptTemplates`（含安全條款：繁中、不評斷天分、不能力評分、僅可編輯草稿）
  - `ParentMessagePreviewView` / `LessonSummaryView`：複製到剪貼簿、無自動發送
- **30 個 unit test 全綠**（含 8 個 AI prompt / mock provider 行為測試）

## 架構

```
MusicTeacherStudio/
  App/             # 進入點 + TabView
  Models/          # SwiftData @Model
  Services/        # 純 Swift 服務
  Views/           # SwiftUI 畫面
  Utilities/       # 格式化 / 檔案 / Preview seed
  Resources/       # Info.plist / Assets
MusicTeacherStudioTests/  # XCTest
project.yml         # XcodeGen 設定
AGENTS.md           # 給 Codex/Claude 的專案規範
```
