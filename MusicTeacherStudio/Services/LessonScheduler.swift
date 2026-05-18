import Foundation

struct LessonScheduler {
    func createOneOffLesson(
        studentID: UUID,
        start: Date,
        durationMinutes: Int,
        feeCents: Int
    ) -> Lesson {
        let end = start.addingTimeInterval(TimeInterval(durationMinutes * 60))
        return Lesson(
            studentID: studentID,
            scheduledStart: start,
            scheduledEnd: end,
            status: .scheduled,
            feeCents: feeCents
        )
    }

    func createRecurringTemplate(
        studentID: UUID,
        weekday: Int,
        startTimeHour: Int,
        startTimeMinute: Int,
        durationMinutes: Int,
        feeCents: Int,
        note: String?
    ) -> RecurringLessonTemplate {
        RecurringLessonTemplate(
            studentID: studentID,
            weekday: weekday,
            startTimeHour: startTimeHour,
            startTimeMinute: startTimeMinute,
            durationMinutes: durationMinutes,
            feeCents: feeCents,
            isActive: true,
            note: note
        )
    }

    /// Generate lessons matching `template.weekday` for `weeksAhead` weeks starting at `startDate`.
    /// Skips any time slot that already exists in `existingLessons` (same student + same scheduledStart).
    func generateLessons(
        from template: RecurringLessonTemplate,
        startingFrom startDate: Date,
        weeksAhead: Int,
        existingLessons: [Lesson],
        calendar: Calendar = .current
    ) -> [Lesson] {
        guard template.isActive, weeksAhead > 0 else { return [] }

        let existingKeys: Set<String> = Set(existingLessons
            .filter { $0.studentID == template.studentID }
            .map { Self.key(studentID: $0.studentID, start: $0.scheduledStart) })

        var generated: [Lesson] = []
        let dayStart = calendar.startOfDay(for: startDate)
        let totalDays = weeksAhead * 7

        for offset in 0..<totalDays {
            guard let day = calendar.date(byAdding: .day, value: offset, to: dayStart) else { continue }
            let wd = calendar.component(.weekday, from: day)
            guard wd == template.weekday else { continue }
            var comps = calendar.dateComponents([.year, .month, .day], from: day)
            comps.hour = template.startTimeHour
            comps.minute = template.startTimeMinute
            comps.second = 0
            guard let start = calendar.date(from: comps) else { continue }
            if start < startDate { continue }
            let k = Self.key(studentID: template.studentID, start: start)
            if existingKeys.contains(k) { continue }
            let end = start.addingTimeInterval(TimeInterval(template.durationMinutes * 60))
            generated.append(Lesson(
                studentID: template.studentID,
                scheduledStart: start,
                scheduledEnd: end,
                status: .scheduled,
                feeCents: template.feeCents
            ))
        }
        return generated
    }

    func cancelLesson(_ lesson: Lesson, note: String? = nil) {
        lesson.status = .cancelled
        if let note { lesson.teacherNote = note }
        lesson.updatedAt = .now
    }

    private static func key(studentID: UUID, start: Date) -> String {
        "\(studentID.uuidString)|\(Int(start.timeIntervalSince1970))"
    }
}
