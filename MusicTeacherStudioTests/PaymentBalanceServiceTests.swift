import XCTest
import SwiftData
@testable import MusicTeacherStudio

final class PaymentBalanceServiceTests: XCTestCase {
    var container: ModelContainer!
    var ctx: ModelContext!
    let svc = PaymentBalanceService()
    let studentID = UUID()

    override func setUpWithError() throws {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: Student.self, Lesson.self, PaymentRecord.self,
                 Assignment.self, PracticeRecording.self, RecurringLessonTemplate.self,
            configurations: cfg
        )
        ctx = ModelContext(container)
    }

    private func lesson(status: LessonStatus, paid: Bool, fee: Int = 1000) -> Lesson {
        Lesson(studentID: studentID,
               scheduledStart: .now, scheduledEnd: .now.addingTimeInterval(3600),
               status: status, feeCents: fee, paid: paid)
    }

    func testAttendedUnpaidCountedAsOutstanding() {
        let lessons = [lesson(status: .attended, paid: false, fee: 800)]
        XCTAssertEqual(svc.outstandingBalanceCents(for: studentID, lessons: lessons), 800)
    }

    func testNoShowUnpaidCountedAsOutstanding() {
        let lessons = [lesson(status: .noShow, paid: false, fee: 600)]
        XCTAssertEqual(svc.outstandingBalanceCents(for: studentID, lessons: lessons), 600)
    }

    func testScheduledNotCounted() {
        let lessons = [lesson(status: .scheduled, paid: false, fee: 1000)]
        XCTAssertEqual(svc.outstandingBalanceCents(for: studentID, lessons: lessons), 0)
    }

    func testCancelledNotCounted() {
        let lessons = [lesson(status: .cancelled, paid: false, fee: 1000)]
        XCTAssertEqual(svc.outstandingBalanceCents(for: studentID, lessons: lessons), 0)
    }

    func testPaidNotCounted() {
        let lessons = [lesson(status: .attended, paid: true, fee: 1000)]
        XCTAssertEqual(svc.outstandingBalanceCents(for: studentID, lessons: lessons), 0)
    }

    func testSumOfMultipleUnpaidLessons() {
        let lessons = [
            lesson(status: .attended, paid: false, fee: 800),
            lesson(status: .noShow,   paid: false, fee: 600),
            lesson(status: .attended, paid: true,  fee: 1000),
            lesson(status: .cancelled,paid: false, fee: 500)
        ]
        XCTAssertEqual(svc.outstandingBalanceCents(for: studentID, lessons: lessons), 1400)
    }

    func testCreatePaymentMarksLessonPaid() {
        let l = lesson(status: .attended, paid: false, fee: 800)
        ctx.insert(l)
        let p = svc.createPayment(for: l, method: "cash", note: nil)
        XCTAssertTrue(l.paid)
        XCTAssertEqual(p.amountCents, 800)
        XCTAssertEqual(p.lessonID, l.id)
    }
}
