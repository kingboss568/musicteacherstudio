import Foundation
import SwiftData

@Model
final class Assignment {
    var id: UUID
    var studentID: UUID
    var lessonID: UUID?
    var title: String
    var instruction: String
    var dueDate: Date?
    var statusRawValue: String
    var createdAt: Date
    var updatedAt: Date

    var status: AssignmentStatus {
        get { AssignmentStatus(rawValue: statusRawValue) ?? .open }
        set { statusRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        studentID: UUID,
        lessonID: UUID? = nil,
        title: String,
        instruction: String,
        dueDate: Date? = nil,
        status: AssignmentStatus = .open,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.studentID = studentID
        self.lessonID = lessonID
        self.title = title
        self.instruction = instruction
        self.dueDate = dueDate
        self.statusRawValue = status.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
