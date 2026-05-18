import Foundation
import SwiftData

@Model
final class PracticeRecording {
    var id: UUID
    var studentID: UUID
    var assignmentID: UUID?
    var localFilePath: String
    var originalFileName: String?
    var recordedAt: Date
    var teacherFeedback: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        studentID: UUID,
        assignmentID: UUID? = nil,
        localFilePath: String,
        originalFileName: String? = nil,
        recordedAt: Date = .now,
        teacherFeedback: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.studentID = studentID
        self.assignmentID = assignmentID
        self.localFilePath = localFilePath
        self.originalFileName = originalFileName
        self.recordedAt = recordedAt
        self.teacherFeedback = teacherFeedback
        self.createdAt = createdAt
    }
}
