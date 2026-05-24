import Foundation

/// 智慧提醒：根據資料計算出今天/本週需要老師注意的事項。
/// 不需要系統通知權限，純粹是 App 內呈現。
struct SmartRemindersService {

    enum Severity { case info, warning, alert }

    struct Reminder: Identifiable {
        let id = UUID()
        let symbol: String
        let title: String
        let detail: String
        let severity: Severity
        let actionLabel: String?
    }

    func generate(
        students: [Student],
        lessons: [Lesson],
        assignments: [Assignment],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [Reminder] {
        var out: [Reminder] = []
        let payService = PaymentBalanceService()
        let studentByID = Dictionary(uniqueKeysWithValues: students.map { ($0.id, $0) })

        // 1) 接下來 2 小時內有課程
        let in2h = now.addingTimeInterval(2 * 3600)
        let upcoming = lessons
            .filter { $0.status == .scheduled && $0.scheduledStart > now && $0.scheduledStart <= in2h }
            .sorted { $0.scheduledStart < $1.scheduledStart }
            .prefix(3)
        for lesson in upcoming {
            let s = studentByID[lesson.studentID]
            let when = DateFormatterUtility.timeString(lesson.scheduledStart)
            out.append(Reminder(
                symbol: "clock.badge.exclamationmark.fill",
                title: "即將上課：\(s?.name ?? "—")",
                detail: "\(when) · \(s?.instrument ?? "")",
                severity: .info,
                actionLabel: "查看"
            ))
        }

        // 2) 已過期未紀錄的課程（昨天或更早，仍 scheduled）
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: now)!
        let overdue = lessons
            .filter { $0.status == .scheduled && $0.scheduledEnd < dayAgo }
            .prefix(3)
        for lesson in overdue {
            let s = studentByID[lesson.studentID]
            out.append(Reminder(
                symbol: "exclamationmark.triangle.fill",
                title: "尚未紀錄：\(s?.name ?? "—")",
                detail: DateFormatterUtility.dateTimeString(lesson.scheduledStart),
                severity: .warning,
                actionLabel: "補登"
            ))
        }

        // 3) 高欠款學生（> NT$2,000）
        let highBalance = students.compactMap { s -> Reminder? in
            let bal = payService.outstandingBalanceCents(for: s.id, lessons: lessons)
            guard bal >= 2000 else { return nil }
            return Reminder(
                symbol: "exclamationmark.circle.fill",
                title: "\(s.name) 欠款 \(MoneyFormatter.string(fromCents: bal))",
                detail: "建議本週溝通",
                severity: .alert,
                actionLabel: "提醒"
            )
        }.prefix(3)
        out.append(contentsOf: highBalance)

        // 4) 作業即將到期（3 天內）
        let in3d = calendar.date(byAdding: .day, value: 3, to: now)!
        let dueSoon = assignments
            .filter { a in
                guard a.status == .open, let due = a.dueDate else { return false }
                return due >= now && due <= in3d
            }
            .prefix(3)
        for a in dueSoon {
            let s = studentByID[a.studentID]
            out.append(Reminder(
                symbol: "doc.badge.clock.fill",
                title: "\(a.title) · \(s?.name ?? "")",
                detail: a.dueDate.map { "到期 \(DateFormatterUtility.dateString($0))" } ?? "",
                severity: .info,
                actionLabel: nil
            ))
        }

        return out
    }
}
