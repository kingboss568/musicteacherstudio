import Foundation

struct AnalyticsService {

    struct DailyPoint: Identifiable {
        let id = UUID()
        let day: Date
        let attended: Int
        let cancelled: Int
        let noShow: Int
        var total: Int { attended + cancelled + noShow }
    }

    struct StudentStat: Identifiable {
        let id: UUID
        let name: String
        let attendedCount: Int
        let totalCount: Int
        var attendanceRate: Double { totalCount == 0 ? 0 : Double(attendedCount) / Double(totalCount) }
        let outstandingCents: Int
    }

    /// Build per-day lesson buckets within a date range.
    func dailySeries(
        lessons: [Lesson],
        daysBack: Int,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [DailyPoint] {
        let end = calendar.startOfDay(for: now)
        let start = calendar.date(byAdding: .day, value: -(daysBack - 1), to: end) ?? end
        var bucket: [Date: (Int, Int, Int)] = [:]
        var d = start
        while d <= end {
            bucket[d] = (0, 0, 0)
            d = calendar.date(byAdding: .day, value: 1, to: d) ?? d.addingTimeInterval(86_400)
        }
        for l in lessons {
            let day = calendar.startOfDay(for: l.scheduledStart)
            guard day >= start && day <= end else { continue }
            var (a, c, n) = bucket[day] ?? (0, 0, 0)
            switch l.status {
            case .attended:  a += 1
            case .cancelled: c += 1
            case .noShow:    n += 1
            case .scheduled: break
            }
            bucket[day] = (a, c, n)
        }
        return bucket
            .map { DailyPoint(day: $0.key, attended: $0.value.0, cancelled: $0.value.1, noShow: $0.value.2) }
            .sorted { $0.day < $1.day }
    }

    func studentStats(
        students: [Student],
        lessons: [Lesson],
        balanceService: PaymentBalanceService = PaymentBalanceService()
    ) -> [StudentStat] {
        students.map { s in
            let theirs = lessons.filter { $0.studentID == s.id }
            let done = theirs.filter { $0.status == .attended || $0.status == .cancelled || $0.status == .noShow }
            let attended = theirs.filter { $0.status == .attended }.count
            return StudentStat(
                id: s.id, name: s.name,
                attendedCount: attended,
                totalCount: done.count,
                outstandingCents: balanceService.outstandingBalanceCents(for: s.id, lessons: lessons)
            )
        }
        .sorted { $0.attendanceRate > $1.attendanceRate }
    }

    /// % of lessons scheduled today that have been completed (attended / cancelled / noShow).
    func todayProgress(lessons: [Lesson], now: Date = .now, calendar: Calendar = .current) -> Double {
        let today = lessons.filter { calendar.isDate($0.scheduledStart, inSameDayAs: now) }
        guard !today.isEmpty else { return 0 }
        let done = today.filter { $0.status != .scheduled }.count
        return Double(done) / Double(today.count)
    }

    /// Total outstanding across all students.
    func totalOutstandingCents(students: [Student], lessons: [Lesson],
                               balanceService: PaymentBalanceService = PaymentBalanceService()) -> Int {
        students.reduce(0) { acc, s in
            acc + balanceService.outstandingBalanceCents(for: s.id, lessons: lessons)
        }
    }
}
