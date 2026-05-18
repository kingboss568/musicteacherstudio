import Foundation
import SwiftData

@Model
final class Student {
    var id: UUID
    var name: String
    var instrument: String
    var level: String?
    var parentName: String?
    var parentContact: String?
    var defaultLessonFeeCents: Int
    var note: String?
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        instrument: String,
        level: String? = nil,
        parentName: String? = nil,
        parentContact: String? = nil,
        defaultLessonFeeCents: Int = 0,
        note: String? = nil,
        isActive: Bool = true,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.instrument = instrument
        self.level = level
        self.parentName = parentName
        self.parentContact = parentContact
        self.defaultLessonFeeCents = defaultLessonFeeCents
        self.note = note
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
