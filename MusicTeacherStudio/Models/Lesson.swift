import Foundation
import SwiftData

@Model
final class Lesson {
    var id: UUID
    var studentID: UUID
    var scheduledStart: Date
    var scheduledEnd: Date
    var statusRawValue: String
    var feeCents: Int
    var paid: Bool
    var teacherNote: String?
    var createdAt: Date
    var updatedAt: Date

    var status: LessonStatus {
        get { LessonStatus(rawValue: statusRawValue) ?? .scheduled }
        set { statusRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        studentID: UUID,
        scheduledStart: Date,
        scheduledEnd: Date,
        status: LessonStatus = .scheduled,
        feeCents: Int,
        paid: Bool = false,
        teacherNote: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.studentID = studentID
        self.scheduledStart = scheduledStart
        self.scheduledEnd = scheduledEnd
        self.statusRawValue = status.rawValue
        self.feeCents = feeCents
        self.paid = paid
        self.teacherNote = teacherNote
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
