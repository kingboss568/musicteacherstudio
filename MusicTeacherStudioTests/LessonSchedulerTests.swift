import XCTest
@testable import MusicTeacherStudio

final class LessonSchedulerTests: XCTestCase {
    let scheduler = LessonScheduler()
    let studentID = UUID()

    func testCreateOneOffLesson() {
        let start = Date()
        let l = scheduler.createOneOffLesson(studentID: studentID, start: start,
                                             durationMinutes: 60, feeCents: 800)
        XCTAssertEqual(l.studentID, studentID)
        XCTAssertEqual(l.scheduledEnd.timeIntervalSince(l.scheduledStart), 3600)
        XCTAssertEqual(l.feeCents, 800)
        XCTAssertEqual(l.status, .scheduled)
    }

    func testGenerateLessonsForFourWeeks() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Taipei")!
        let weekday = 4 // Wednesday
        let tpl = scheduler.createRecurringTemplate(
            studentID: studentID, weekday: weekday,
            startTimeHour: 16, startTimeMinute: 0,
            durationMinutes: 60, feeCents: 800, note: nil
        )
        // Start from a known Wednesday: 2026-01-07
        let start = cal.date(from: DateComponents(year: 2026, month: 1, day: 7))!
        let generated = scheduler.generateLessons(from: tpl, startingFrom: start,
                                                  weeksAhead: 4, existingLessons: [],
                                                  calendar: cal)
        XCTAssertEqual(generated.count, 4)
        for l in generated {
            XCTAssertEqual(cal.component(.weekday, from: l.scheduledStart), weekday)
            XCTAssertEqual(cal.component(.hour, from: l.scheduledStart), 16)
        }
    }

    func testGenerateLessonsSkipsExistingSlots() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Taipei")!
        let tpl = scheduler.createRecurringTemplate(
            studentID: studentID, weekday: 4,
            startTimeHour: 16, startTimeMinute: 0,
            durationMinutes: 60, feeCents: 800, note: nil
        )
        let start = cal.date(from: DateComponents(year: 2026, month: 1, day: 7))!
        // Pre-existing lesson on 2026-01-14 at 16:00 (the 2nd occurrence)
        let existingStart = cal.date(from: DateComponents(year: 2026, month: 1, day: 14, hour: 16))!
        let existing = Lesson(studentID: studentID,
                              scheduledStart: existingStart,
                              scheduledEnd: existingStart.addingTimeInterval(3600),
                              feeCents: 800)
        let generated = scheduler.generateLessons(from: tpl, startingFrom: start,
                                                  weeksAhead: 4, existingLessons: [existing],
                                                  calendar: cal)
        XCTAssertEqual(generated.count, 3)
        XCTAssertFalse(generated.contains { $0.scheduledStart == existingStart })
    }

    func testCancelLessonUpdatesStatus() {
        let l = scheduler.createOneOffLesson(studentID: studentID, start: .now,
                                             durationMinutes: 60, feeCents: 800)
        scheduler.cancelLesson(l, note: "請假")
        XCTAssertEqual(l.status, .cancelled)
        XCTAssertEqual(l.teacherNote, "請假")
    }
}
