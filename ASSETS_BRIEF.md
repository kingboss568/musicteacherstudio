# 視覺素材生成清單（給 ChatGPT / DALL·E / Midjourney）

> 把以下每個 prompt 貼到 ChatGPT（Image）或 Midjourney v6+，生成後請依檔名說明放到 `MusicTeacherStudio/Resources/Assets.xcassets/`。

## 品牌風格基準（每個 prompt 都會帶這段）

```
Brand: "音律手帳 / MusicTeacher Studio"
Style: minimal, warm, premium, paper-textured, soft gradients
Palette:
  - Deep indigo #4F28DA / #6D28D9 (primary)
  - Warm gold #F59E0B (accent)
  - Off-white #FAFAF7 (surface)
  - Charcoal #18181B (ink)
Avoid: cliché stock photos, generic music notes-only design, neon, flat emoji.
Mood: "a beautifully designed paper notebook for a music teacher, calm and trustworthy"
```

---

## 1. App Icon（1024×1024 PNG，no alpha，sRGB）

**目的**：App Store 主圖示。
**Prompt（ChatGPT Image）**：

```
A premium iOS app icon, 1024x1024, no transparency, no rounded mask (Apple adds it).
Subject: A stylised paper notebook with a single elegant treble clef debossed into the cover,
overlaid with a soft tuning-fork mark in warm gold leaf.
Background: a smooth deep indigo to violet diagonal gradient (#4F28DA → #6D28D9).
Add a subtle paper grain texture and a faint embossed beat-mark in the top right.
Lighting: soft top-left highlight, gentle shadow on bottom-right.
NO text, NO numbers, NO Apple logos. Style: minimal, refined, premium, 2026 design language.
Output as a single centered icon filling 100% of the 1024x1024 canvas.
```

**放置**：覆蓋 `Assets.xcassets/AppIcon.appiconset/` 內 `icon-1024.png`，再用 `mkappicon` / Xcode 自動展開其他尺寸。

---

## 2. Onboarding 插圖（×4，每張 1080×1080 PNG，透明背景）

四張對應 `OnboardingView.pages`：

### 2.1 OnboardingHero1 — 30 秒紀錄

```
A flat-design illustration, 1080x1080, transparent background.
Scene: a teacher's hand placing a single check-mark on a glowing paper card that reads "課堂筆記" (subtle, optional). 
A soft indigo gradient halo, paper grain. A small stopwatch shows "0:30" elegantly.
Style: warm minimal vector art, premium brand feel. Palette as brand basis.
NO realistic faces, NO logos, NO photo realism.
```

### 2.2 OnboardingAI — AI 草稿

```
1080x1080 transparent. Illustration of two paper envelopes stacked, with a soft golden quill writing on top, faint sparkle particles. 
A speech bubble shape behind the envelopes hints at a draft message. 
Indigo + warm gold tones.
```

### 2.3 OnboardingCharts — 進度圖表

```
1080x1080 transparent. Illustration of an abstract bar chart on a paper notebook, lines drawn like staff lines. 
Bars colored in deep indigo gradient with one golden bar standing taller (representing growth). 
Faint metronome silhouette in background. Warm, minimal, paper-textured.
```

### 2.4 OnboardingPro — Pro 解鎖

```
1080x1080 transparent. Illustration of a small gold crown floating above an opened paper notebook. 
Soft gold particle confetti, indigo gradient backdrop fade. Premium feel, no realistic gold metallic, just warm matte gold (#F59E0B + #FBBF24 highlights).
```

**放置**：`Assets.xcassets/` 新增 imageset：`OnboardingHero1`、`OnboardingAI`、`OnboardingCharts`、`OnboardingPro`，將 PNG 標記為 1x / 2x / 3x（或 Universal）。然後把 `OnboardingView.swift` 內 `Image(systemName:)` 改為 `Image("OnboardingHero1")` 即可（目前用 SF Symbol 占位）。

---

## 3. 空狀態插圖（×3）

當「沒有學生 / 沒有課程 / 沒有作業」時顯示。

### 3.1 EmptyStudents

```
1080x1080 transparent. Minimal line illustration of three tiny stick figures holding tiny instruments (piano, violin, guitar) standing in front of a small staff line. Warm indigo line art, no fills. 
Style: hand-drawn, 1.5px stroke, paper background-friendly.
```

### 3.2 EmptyLessons

```
1080x1080 transparent. Minimal line illustration of a calendar page with a single treble clef drawn inside today's date cell. 
Indigo strokes, gold accent on the clef. Hand-drawn, warm.
```

### 3.3 EmptyAssignments

```
1080x1080 transparent. Minimal line illustration of a folded paper note with a music notation snippet and a checkbox. 
Indigo strokes, warm gold checkbox accent.
```

---

## 4. PDF 學習歷程封面圖（1240×360 PNG）

用於 `StudentProgressReportRenderer` 頂部 brand bar 之下：

```
1240x360, no transparency.
Scene: A serene desk with a sheet of music staff paper, soft indigo gradient washing from left to right, with two tiny gold treble-clef symbols on the right side.
Mood: calm, trustworthy, designed for parents to enjoy reading.
No text, no faces.
```

**放置**：`Assets.xcassets/ReportCover.imageset/` (1x/2x/3x)，並更新 `StudentProgressReportRenderer.swift` 用 `UIImage(named:)` 拉進去畫。

---

## 5. Paywall 視覺背景（選用，1080×1920）

```
1080x1920, premium paywall hero background. 
Soft indigo-to-violet vertical gradient overlaid with very faint paper texture, a single warm-gold treble-clef debossed in the center-top with subtle bloom. 
Bottom 30% gradients to slightly darker indigo for text legibility.
No text, no logos. Minimal premium aesthetic, 2026.
```

**放置**：`Assets.xcassets/PaywallBackdrop.imageset/`，然後 `PaywallView.swift` 把 `LinearGradient` 換成 `Image("PaywallBackdrop").resizable().ignoresSafeArea()`。

---

## 6. App Store 截圖底圖（×6，1290×2796 iPhone 6.9″）

每張截圖一個底圖 + Title 字。建議在 Figma 排版或用 ChatGPT 直接生成包含 title 的版本。

### 通用版型

```
1290x2796 portrait. A muted indigo gradient background with paper texture.
Top 25%: bold Traditional Chinese marketing headline (placeholder).
Middle 65%: large empty space (will paste the app simulator screenshot here in Figma).
Bottom 10%: 音律手帳 logo placeholder.
```

### 6 個 Title 文案

1. **30 秒記錄一堂課**
2. **學生欠款一眼掌握**
3. **AI 家長訊息 · 老師說了算**
4. **進度趨勢圖看得見成長**
5. **內建節拍器 / 調音 / 批次訊息**
6. **CSV 備份 · 安心交接**

---

## 7. Notification & Widget icons（選用，未來）

```
Pair of 192x192 transparent PNGs:
- A small treble-clef glyph with gold accent
- A small paper-with-checkmark glyph
Both in monoline minimal style matching brand.
```

---

## 操作流程

1. 用 ChatGPT「圖像」工具或 Midjourney 跑出每張 PNG。
2. PNG 收進 `Assets.xcassets/<Name>.imageset/` 並設定 1x/2x/3x（universal）。
3. 跑 `xcodegen generate` 重新產 project。
4. 程式碼裡把 `Image(systemName: "music.note.list")` 等 SF Symbol 占位換成 `Image("Asset名稱")`。
5. AppIcon 用 https://www.appicon.co/ 或 `mkappicon` 一鍵展開所有尺寸並覆蓋 `AppIcon.appiconset`。
