import XCTest
@testable import MusicTeacherStudio

final class AttendanceServiceTests: XCTestCase {
    let svc = AttendanceService()

    private func makeLesson() -> Lesson {
        Lesson(studentID: UUID(), scheduledStart: .now,
               scheduledEnd: .now.addingTimeInterval(3600), feeCents: 800)
    }

    func testMarkAttendedWithNote() {
        let l = makeLesson()
        svc.markAttended(l, note: "ok")
        XCTAssertEqual(l.status, .attended)
        XCTAssertEqual(l.teacherNote, "ok")
    }

    func testMarkCancelled() {
        let l = makeLesson()
        svc.markCancelled(l, note: "請假")
        XCTAssertEqual(l.status, .cancelled)
        XCTAssertEqual(l.teacherNote, "請假")
    }

    func testMarkNoShow() {
        let l = makeLesson()
        svc.markNoShow(l)
        XCTAssertEqual(l.status, .noShow)
    }

    func testUpdateTeacherNote() {
        let l = makeLesson()
        svc.updateTeacherNote(l, note: "新筆記")
        XCTAssertEqual(l.teacherNote, "新筆記")
    }
}
