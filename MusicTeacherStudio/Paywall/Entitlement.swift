import Foundation

/// Single source of truth for Pro feature gating.
enum Entitlement: String, Codable, CaseIterable {
    case unlimitedStudents
    case unlimitedAIDrafts
    case advancedAITones
    case multilingualAI
    case csvImportExport
    case batchMessaging
    case customPDFBranding
    case bilingualPDF
    case advancedAnalytics
    case studioBackupPack
    case removeWatermark
    case advancedTuner

    var displayName: String {
        switch self {
        case .unlimitedStudents:    return "無限學生人數"
        case .unlimitedAIDrafts:    return "AI 草稿無限次"
        case .advancedAITones:      return "AI 多版本草稿輸出"
        case .multilingualAI:       return "AI 家長訊息語氣包"
        case .csvImportExport:      return "CSV 匯出與備份包"
        case .batchMessaging:       return "批次家長訊息"
        case .customPDFBranding:    return "PDF 專業版樣式"
        case .bilingualPDF:         return "雙語 PDF"
        case .advancedAnalytics:    return "進階儀表板（無限歷史）"
        case .studioBackupPack:     return "本機資料備份與交接"
        case .removeWatermark:      return "移除浮水印"
        case .advancedTuner:        return "全功能調音器 / 節拍器"
        }
    }

    var symbol: String {
        switch self {
        case .unlimitedStudents:    return "person.3.fill"
        case .unlimitedAIDrafts:    return "sparkles"
        case .advancedAITones:      return "waveform.path.ecg"
        case .multilingualAI:       return "text.bubble.fill"
        case .csvImportExport:      return "tablecells.fill"
        case .batchMessaging:       return "envelope.badge.fill"
        case .customPDFBranding:    return "paintpalette.fill"
        case .bilingualPDF:         return "doc.text.image.fill"
        case .advancedAnalytics:    return "chart.line.uptrend.xyaxis"
        case .studioBackupPack:     return "externaldrive.fill"
        case .removeWatermark:      return "checkmark.seal.fill"
        case .advancedTuner:        return "tuningfork"
        }
    }
}

/// Free-tier hard caps.
enum FreeLimits {
    static let maxStudents = 3
    static let aiParentMessagesPerMonth = 5
    static let aiSummariesPerMonth = 1
    static let analyticsDaysBack = 7
}
