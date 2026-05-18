import Foundation
import SwiftData

@Model
final class RecurringLessonTemplate {
    var id: UUID
    var studentID: UUID
    var weekday: Int        // Calendar weekday: Sunday=1 ... Saturday=7
    var startTimeHour: Int
    var startTimeMinute: Int
    var durationMinutes: Int
    var feeCents: Int
    var isActive: Bool
    var note: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        studentID: UUID,
        weekday: Int,
        startTimeHour: Int,
        startTimeMinute: Int,
        durationMinutes: Int,
        feeCents: Int,
        isActive: Bool = true,
        note: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.studentID = studentID
        self.weekday = weekday
        self.startTimeHour = startTimeHour
        self.startTimeMinute = startTimeMinute
        self.durationMinutes = durationMinutes
        self.feeCents = feeCents
        self.isActive = isActive
        self.note = note
        self.createdAt = createdAt
    }
}
