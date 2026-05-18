import Foundation

enum DateFormatterUtility {
    private static let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_Hant_TW")
        f.dateFormat = "yyyy/MM/dd"
        return f
    }()

    private static let timeFmt: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_Hant_TW")
        f.dateFormat = "HH:mm"
        return f
    }()

    private static let dateTimeFmt: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_Hant_TW")
        f.dateFormat = "yyyy/MM/dd HH:mm"
        return f
    }()

    private static let fileFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f
    }()

    private static let dayKeyFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func dateString(_ date: Date) -> String { dateFmt.string(from: date) }
    static func timeString(_ date: Date) -> String { timeFmt.string(from: date) }
    static func dateTimeString(_ date: Date) -> String { dateTimeFmt.string(from: date) }
    static func fileDateString(_ date: Date) -> String { fileFmt.string(from: date) }
    static func dayKey(_ date: Date) -> String { dayKeyFmt.string(from: date) }
}
