import Foundation
import SwiftData

@Model
final class PaymentRecord {
    var id: UUID
    var studentID: UUID
    var lessonID: UUID?
    var amountCents: Int
    var paidAt: Date
    var method: String?
    var note: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        studentID: UUID,
        lessonID: UUID? = nil,
        amountCents: Int,
        paidAt: Date = .now,
        method: String? = nil,
        note: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.studentID = studentID
        self.lessonID = lessonID
        self.amountCents = amountCents
        self.paidAt = paidAt
        self.method = method
        self.note = note
        self.createdAt = createdAt
    }
}
