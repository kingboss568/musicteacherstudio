# App Store 上架資料包

## 基本資訊

| 欄位 | 值 |
|---|---|
| Bundle ID | `com.jiang.musicteacherstudio` |
| App 名稱 | 樂課管家 - 音樂老師課程管理 |
| 副標題 | 30 秒課後紀錄、收費追蹤、AI 家長草稿 |
| 主要類別 | 教育 |
| 次要類別 | 生產力 |
| 目標年齡 | 4+ |
| 主要語言 | 繁體中文（zh-Hant-TW） |
| 價格 | 免費下載，App 內購買解鎖 Pro |
| Support URL | `https://kingboss568.github.io/musicteacherstudio/support` |
| Privacy Policy URL | `https://kingboss568.github.io/musicteacherstudio/privacy` |
| Terms URL | `https://kingboss568.github.io/musicteacherstudio/terms` |

## 內購

| Product ID | 類型 | 顯示名稱 | 建議價格 |
|---|---|---|---|
| `studio.pro.monthly` | Auto-renewable Subscription | 樂課管家 Pro 月訂閱 | NT$120 |
| `studio.pro.yearly` | Auto-renewable Subscription | 樂課管家 Pro 年訂閱 | NT$990 |
| `studio.pro.lifetime` | Non-Consumable | 樂課管家 Pro 終身版 | NT$2,490 |

訂閱群組：`Music Teacher Studio Pro`  
月訂閱：7 天免費試用。  
年訂閱：主打最佳價值。  
終身版：一次付費永久解鎖。

## App Store 描述（繁中）

```text
樂課管家是為私人音樂老師打造的課程管理 App。

它把學生、課表、出席、課費、作業、錄音回饋、學習報表與家長訊息草稿放在同一個離線優先的工作台，讓老師在 30 秒內完成一堂課後紀錄，把行政時間還給教學。

免費版即可使用：
・最多 3 位學生
・課表、出席、課堂筆記與課費紀錄
・欠款追蹤與近期付款紀錄
・作業建立與狀態追蹤
・手動匯入學生練習錄音
・學習歷程 PDF 匯出
・內建節拍器與調音音叉
・AI 家長訊息草稿與學習摘要（本機模板、可編輯）
・所有核心資料離線可用

升級 Pro，建立完整教學工作室：
・無限學生人數
・AI 草稿無限次，支援進階語氣包與長短版本
・進階儀表板：長期出席、欠款與作業趨勢
・批次家長訊息，一次整理多位學生通知
・CSV 匯出與本機備份包
・雙語 PDF、專業版樣式、移除試用浮水印
・全功能節拍器與 12 音調音器

AI 永遠只是草稿。老師確認後才複製或傳送；App 不評斷學生天分、不做能力排名、不替老師做教學判斷。

隱私：
本版本沒有後端伺服器、不使用廣告、不使用第三方分析。資料只保存在你的 iPhone / iPad，PDF 或 CSV 只有在你主動分享時才會離開裝置。

訂閱：
月訂閱含 7 天免費試用，試用結束後自動續訂。可隨時於 iPhone「設定 > Apple ID > 訂閱項目」管理或取消。終身版為一次性付費，不會自動續訂。
```

## App Store Description (English)

```text
MusicTeacher Studio is a course-management app for private music teachers.

It brings students, lessons, attendance, fees, assignments, practice recordings, progress reports, and parent-message drafts into one offline-first workspace. Capture a post-lesson record in 30 seconds and spend more time teaching.

Free:
- Up to 3 students
- Lessons, attendance, lesson notes, and fee tracking
- Outstanding balance and payment history
- Assignment tracking
- Manual practice-recording import
- Local PDF learning reports
- Built-in metronome and tuning fork
- AI parent-message drafts and learning summaries (local templates, editable)
- Core data works offline

Pro:
- Unlimited students
- Unlimited AI drafts with advanced tones and length options
- Advanced analytics for attendance, balance, and assignment trends
- Batch parent messaging
- CSV export and local backup package
- Bilingual PDFs, custom branding, and no trial watermark
- Full metronome and 12-note tuner

AI is draft-only. Teachers review, edit, copy, and send. The app never judges talent, ranks ability, or replaces the teacher's professional judgment.

Privacy:
No backend server, no ads, no third-party analytics. Data stays on the user's iPhone or iPad unless the user manually shares a PDF or CSV file.
```

## 關鍵字

繁中（100 字元內）：

```text
音樂,老師,鋼琴,小提琴,吉他,學生,課表,收費,作業,家長,AI,節拍器,調音器,PDF,離線
```

英文：

```text
music,teacher,piano,violin,guitar,student,lesson,attendance,billing,AI,metronome,tuner,PDF
```

## 截圖規格

Apple 目前接受的重點尺寸：

| 類型 | 可用直向尺寸 |
|---|---|
| iPhone 6.9 吋 | 1260×2736、1290×2796、1320×2868 |
| iPad 13 吋 | 2064×2752、2048×2732 |

官方規格：https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications

## 建議截圖標題

1. 30 秒記錄一堂課
2. 學生欠款一眼掌握
3. AI 家長訊息，老師說了算
4. 進度趨勢看得見成長
5. 作業、錄音、PDF 都能交付
6. Pro 工作室：批次訊息與備份包

## 資料安全填寫建議

| 問題 | 答案 |
|---|---|
| 是否收集資料？ | 否，本版本沒有伺服器與第三方分析 |
| 是否使用 IDFA / 廣告？ | 否 |
| 是否需要登入？ | 否 |
| 是否需要網路？ | 核心功能不需要；StoreKit 內購需 Apple 系統連線 |
| 第三方 SDK | 0 |
| 加密出口宣告 | `ITSAppUsesNonExemptEncryption = false` |

## 審核注意事項

| 風險 | 對應 |
|---|---|
| 2.3.10 未實作功能宣稱 | 已移除未實作的雲端同步、通知與外部 AI 宣稱 |
| 3.1.1 內購 | 所有付費功能走 StoreKit IAP |
| 5.1.1 隱私 | 不使用追蹤、廣告、第三方分析或後端上傳 |
| 4.2 模板化 | App 有學生、課程、收費、錄音、AI 草稿、PDF、節拍器/調音器等完整流程 |

## 上架前 checklist

- [x] AppIcon 1024×1024 已產生
- [x] Support / Privacy / Terms 文件已在 repo
- [x] 內購 Product ID 已放進 StoreKit 設定
- [x] Debug screenshot seed mode 可產生示範資料畫面
- [ ] App Store Connect 建立三個 IAP 並確認 Ready to Submit
- [ ] 使用真實開發者帳號 archive/export IPA
- [ ] 上傳 build 至 App Store Connect
- [ ] 上傳 iPhone 6.9 吋與 iPad 13 吋截圖
- [ ] 送出審查前以真人帳號確認訂閱與還原購買
