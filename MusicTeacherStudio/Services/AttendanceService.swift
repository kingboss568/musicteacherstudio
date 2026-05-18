import Foundation

struct AttendanceService {
    func markAttended(_ lesson: Lesson, note: String? = nil) {
        lesson.status = .attended
        if let note { lesson.teacherNote = note }
        lesson.updatedAt = .now
    }

    func markCancelled(_ lesson: Lesson, note: String? = nil) {
        lesson.status = .cancelled
        if let note { lesson.teacherNote = note }
        lesson.updatedAt = .now
    }

    func markNoShow(_ lesson: Lesson, note: String? = nil) {
        lesson.status = .noShow
        if let note { lesson.teacherNote = note }
        lesson.updatedAt = .now
    }

    func updateTeacherNote(_ lesson: Lesson, note: String) {
        lesson.teacherNote = note
        lesson.updatedAt = .now
    }
}
