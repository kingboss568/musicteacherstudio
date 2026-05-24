import XCTest
@testable import MusicTeacherStudio

final class StreakServiceTests: XCTestCase {
    let svc = StreakService()
    let studentID = UUID()
    let cal = Calendar.current

    private func lesson(daysFromToday: Int, status: LessonStatus = .attended) -> Lesson {
        let day = cal.date(byAdding: .day, value: daysFromToday, to: cal.startOfDay(for: .now))!
        return Lesson(studentID: studentID,
                      scheduledStart: day,
                      scheduledEnd: day.addingTimeInterval(3600),
                      status: status, feeCents: 800)
    }

    func testNoLessonsYieldsZeroStreak() {
        let r = svc.compute(lessons: [])
        XCTAssertEqual(r.currentStreak, 0)
        XCTAssertEqual(r.longestStreak, 0)
        XCTAssertEqual(r.totalActiveDays, 0)
        XCTAssertNil(r.lastActiveDay)
    }

    func testScheduledOnlyDoesNotCountAsActive() {
        let r = svc.compute(lessons: [
            lesson(daysFromToday: 0, status: .scheduled),
            lesson(daysFromToday: -1, status: .scheduled)
        ])
        XCTAssertEqual(r.currentStreak, 0)
        XCTAssertEqual(r.totalActiveDays, 0)
    }

    func testCurrentStreakIncludesToday() {
        let r = svc.compute(lessons: [
            lesson(daysFromToday: 0),
            lesson(daysFromToday: -1),
            lesson(daysFromToday: -2)
        ])
        XCTAssertEqual(r.currentStreak, 3)
        XCTAssertEqual(r.totalActiveDays, 3)
    }

    func testYesterdayGracePeriodKeepsStreakAlive() {
        let r = svc.compute(lessons: [
            lesson(daysFromToday: -1),
            lesson(daysFromToday: -2)
        ])
        // 今天還沒紀錄，但昨天有 → streak 仍為 2（容忍）
        XCTAssertEqual(r.currentStreak, 2)
    }

    func testTwoDayGapBreaksStreak() {
        let r = svc.compute(lessons: [
            lesson(daysFromToday: -3),
            lesson(daysFromToday: -4),
            lesson(daysFromToday: -5)
        ])
        XCTAssertEqual(r.currentStreak, 0)
        XCTAssertEqual(r.longestStreak, 3)
        XCTAssertEqual(r.totalActiveDays, 3)
    }

    func testLongestStreakAcrossGaps() {
        let r = svc.compute(lessons: [
            lesson(daysFromToday: 0),
            // gap
            lesson(daysFromToday: -3),
            lesson(daysFromToday: -4),
            lesson(daysFromToday: -5),
            lesson(daysFromToday: -6)
        ])
        XCTAssertEqual(r.longestStreak, 4)
    }

    func testMultipleLessonsSameDayCountOnce() {
        let r = svc.compute(lessons: [
            lesson(daysFromToday: 0),
            lesson(daysFromToday: 0),
            lesson(daysFromToday: 0)
        ])
        XCTAssertEqual(r.totalActiveDays, 1)
        XCTAssertEqual(r.currentStreak, 1)
    }
}
