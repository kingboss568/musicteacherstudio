import Foundation

struct PaymentBalanceService {
    /// Lessons that count as chargeable AND are still unpaid for the given student.
    /// MVP rule: only `.attended` and `.noShow` are chargeable. `.cancelled` and `.scheduled` do not contribute.
    func chargeableUnpaidLessons(for studentID: UUID, lessons: [Lesson]) -> [Lesson] {
        lessons.filter { l in
            l.studentID == studentID
                && !l.paid
                && (l.status == .attended || l.status == .noShow)
        }
    }

    func outstandingBalanceCents(for studentID: UUID, lessons: [Lesson]) -> Int {
        chargeableUnpaidLessons(for: studentID, lessons: lessons)
            .map(\.feeCents)
            .reduce(0, +)
    }

    func totalPaidCents(for studentID: UUID, payments: [PaymentRecord]) -> Int {
        payments
            .filter { $0.studentID == studentID }
            .map(\.amountCents)
            .reduce(0, +)
    }

    /// Create a PaymentRecord for a specific lesson and mark the lesson paid.
    @discardableResult
    func createPayment(for lesson: Lesson, method: String?, note: String?) -> PaymentRecord {
        lesson.paid = true
        lesson.updatedAt = .now
        return PaymentRecord(
            studentID: lesson.studentID,
            lessonID: lesson.id,
            amountCents: lesson.feeCents,
            paidAt: .now,
            method: method,
            note: note
        )
    }

    func markLessonPaid(_ lesson: Lesson) {
        lesson.paid = true
        lesson.updatedAt = .now
    }
}
