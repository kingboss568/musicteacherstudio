import Foundation
import SwiftData

@MainActor
enum PreviewData {
    static let schema = Schema([
        Student.self,
        Lesson.self,
        Assignment.self,
        PracticeRecording.self,
        PaymentRecord.self,
        RecurringLessonTemplate.self
    ])

    static func makeContainer() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        seed(container.mainContext)
        return container
    }

    static func seed(_ ctx: ModelContext) {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        func at(_ day: Date, hour: Int, minute: Int = 0) -> Date {
            cal.date(bySettingHour: hour, minute: minute, second: 0, of: day)!
        }

        let alice = Student(name: "陳家樂", instrument: "鋼琴", level: "中級",
                            parentName: "陳媽媽", parentContact: "0912-111-111",
                            defaultLessonFeeCents: 800)
        let bob   = Student(name: "林小妮", instrument: "小提琴", level: "初級",
                            parentName: "林爸爸", parentContact: "0922-222-222",
                            defaultLessonFeeCents: 1000)
        let carol = Student(name: "黃志明", instrument: "吉他", level: "中高級",
                            parentName: "黃媽媽", parentContact: "0933-333-333",
                            defaultLessonFeeCents: 900, isActive: true)
        [alice, bob, carol].forEach { ctx.insert($0) }

        // Today: 2 lessons
        let l1 = Lesson(studentID: alice.id, scheduledStart: at(today, hour: 16),
                        scheduledEnd: at(today, hour: 17), status: .scheduled, feeCents: 800)
        let l2 = Lesson(studentID: bob.id, scheduledStart: at(today, hour: 18),
                        scheduledEnd: at(today, hour: 19), status: .scheduled, feeCents: 1000)
        // Past 4 lessons
        let past1 = Lesson(studentID: alice.id, scheduledStart: cal.date(byAdding: .day, value: -7, to: at(today, hour: 16))!,
                           scheduledEnd: cal.date(byAdding: .day, value: -7, to: at(today, hour: 17))!,
                           status: .attended, feeCents: 800, paid: true,
                           teacherNote: "Hanon 1 ok，左手仍偏慢。")
        let past2 = Lesson(studentID: alice.id, scheduledStart: cal.date(byAdding: .day, value: -14, to: at(today, hour: 16))!,
                           scheduledEnd: cal.date(byAdding: .day, value: -14, to: at(today, hour: 17))!,
                           status: .attended, feeCents: 800, paid: false,
                           teacherNote: "新曲試彈，節奏穩定度待加強。")
        let past3 = Lesson(studentID: bob.id, scheduledStart: cal.date(byAdding: .day, value: -7, to: at(today, hour: 18))!,
                           scheduledEnd: cal.date(byAdding: .day, value: -7, to: at(today, hour: 19))!,
                           status: .noShow, feeCents: 1000, paid: false)
        let past4 = Lesson(studentID: carol.id, scheduledStart: cal.date(byAdding: .day, value: -3, to: at(today, hour: 20))!,
                           scheduledEnd: cal.date(byAdding: .day, value: -3, to: at(today, hour: 21))!,
                           status: .cancelled, feeCents: 900, paid: false,
                           teacherNote: "學生臨時請假。")
        [l1, l2, past1, past2, past3, past4].forEach { ctx.insert($0) }

        // Assignments
        let a1 = Assignment(studentID: alice.id, lessonID: past1.id,
                            title: "Hanon No.1 慢速",
                            instruction: "每天 10 分鐘，左右手分開練。",
                            dueDate: cal.date(byAdding: .day, value: 7, to: today),
                            status: .open)
        let a2 = Assignment(studentID: bob.id,
                            title: "G 大調音階",
                            instruction: "每天 5 分鐘上下行。",
                            status: .open)
        [a1, a2].forEach { ctx.insert($0) }

        // Recording (fake path; for preview only)
        let r1 = PracticeRecording(studentID: alice.id, assignmentID: a1.id,
                                   localFilePath: "Recordings/sample.m4a",
                                   originalFileName: "hanon1.m4a",
                                   teacherFeedback: "節奏比上次穩。")
        ctx.insert(r1)

        // Payments
        let p1 = PaymentRecord(studentID: alice.id, lessonID: past1.id, amountCents: 800,
                               method: "現金", note: "5月第1次")
        let p2 = PaymentRecord(studentID: carol.id, amountCents: 2700,
                               method: "轉帳", note: "5月預收三堂")
        [p1, p2].forEach { ctx.insert($0) }

        // Recurring template
        let template = RecurringLessonTemplate(
            studentID: alice.id,
            weekday: cal.component(.weekday, from: today),
            startTimeHour: 16, startTimeMinute: 0,
            durationMinutes: 60, feeCents: 800,
            note: "固定週課"
        )
        ctx.insert(template)
    }
}
