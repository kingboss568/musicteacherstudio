import Foundation

/// 連續紀錄打卡：只要當天有任何「課程被標 attended / cancelled / noShow」就算當天有「紀錄」。
/// 這個機制讓老師每天都想回來打開 App。
struct StreakService {

    struct StreakResult: Equatable {
        var currentStreak: Int   // 連續至今的天數（從今天/昨天起算）
        var longestStreak: Int
        var totalActiveDays: Int
        var lastActiveDay: Date?
    }

    func compute(lessons: [Lesson], now: Date = .now, calendar: Calendar = .current) -> StreakResult {
        let recordedDays: Set<Date> = Set(
            lessons
                .filter { $0.status != .scheduled }
                .map { calendar.startOfDay(for: $0.scheduledStart) }
        )
        guard !recordedDays.isEmpty else {
            return StreakResult(currentStreak: 0, longestStreak: 0, totalActiveDays: 0, lastActiveDay: nil)
        }

        let sortedDays = recordedDays.sorted()
        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        // Current streak: ends at today or yesterday (grace), walk backwards.
        var current = 0
        var cursor: Date
        if recordedDays.contains(today) {
            cursor = today
        } else if recordedDays.contains(yesterday) {
            cursor = yesterday
        } else {
            // No activity in last 2 days → streak is 0.
            return StreakResult(
                currentStreak: 0,
                longestStreak: Self.longest(in: sortedDays, calendar: calendar),
                totalActiveDays: recordedDays.count,
                lastActiveDay: sortedDays.last
            )
        }
        while recordedDays.contains(cursor) {
            current += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor)!
        }

        return StreakResult(
            currentStreak: current,
            longestStreak: max(current, Self.longest(in: sortedDays, calendar: calendar)),
            totalActiveDays: recordedDays.count,
            lastActiveDay: sortedDays.last
        )
    }

    private static func longest(in sortedDays: [Date], calendar: Calendar) -> Int {
        guard !sortedDays.isEmpty else { return 0 }
        var best = 1, run = 1
        for i in 1..<sortedDays.count {
            let prev = sortedDays[i - 1]
            let cur  = sortedDays[i]
            if let next = calendar.date(byAdding: .day, value: 1, to: prev), next == cur {
                run += 1
            } else {
                run = 1
            }
            best = max(best, run)
        }
        return best
    }
}
