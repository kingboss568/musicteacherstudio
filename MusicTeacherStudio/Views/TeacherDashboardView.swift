import SwiftUI
import SwiftData

struct TeacherDashboardView: View {
    @Environment(\.modelContext) private var ctx
    @Query private var students: [Student]
    @Query(sort: \Lesson.scheduledStart) private var lessons: [Lesson]
    @Query private var assignments: [Assignment]
    @Query private var payments: [PaymentRecord]

    @State private var showStudentEditor = false
    @State private var showLessonEditor = false

    private let attendance = AttendanceService()
    private let payService = PaymentBalanceService()

    private var todayLessons: [Lesson] {
        let cal = Calendar.current
        return lessons.filter { cal.isDateInToday($0.scheduledStart) }
    }

    private var openAssignments: [Assignment] {
        assignments.filter { $0.status == .open }
    }

    private var studentsWithBalance: [(Student, Int)] {
        students.map { s in
            (s, payService.outstandingBalanceCents(for: s.id, lessons: lessons))
        }
        .filter { $0.1 > 0 }
        .sorted { $0.1 > $1.1 }
    }

    var body: some View {
        List {
            Section("今日課程") {
                if todayLessons.isEmpty {
                    Text("今天沒有課").foregroundStyle(.secondary)
                } else {
                    ForEach(todayLessons) { lesson in
                        TodayLessonRow(lesson: lesson,
                                       student: student(for: lesson.studentID),
                                       attendance: attendance)
                    }
                }
            }

            Section("近期未完成作業") {
                if openAssignments.isEmpty {
                    Text("無").foregroundStyle(.secondary)
                } else {
                    ForEach(openAssignments) { a in
                        VStack(alignment: .leading) {
                            Text(a.title).font(.body)
                            Text(student(for: a.studentID)?.name ?? "—")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("欠款提醒") {
                if studentsWithBalance.isEmpty {
                    Text("無").foregroundStyle(.secondary)
                } else {
                    ForEach(studentsWithBalance, id: \.0.id) { (s, balance) in
                        HStack {
                            Text(s.name)
                            Spacer()
                            Text(MoneyFormatter.string(fromCents: balance))
                                .foregroundStyle(.red)
                        }
                    }
                }
            }

            Section("快速操作") {
                Button { showStudentEditor = true } label: { Label("新增學生", systemImage: "person.badge.plus") }
                Button { showLessonEditor = true }  label: { Label("新增課程", systemImage: "calendar.badge.plus") }
                NavigationLink { StudentListView() }      label: { Label("學生列表", systemImage: "person.2") }
                NavigationLink { PaymentTrackerView() }   label: { Label("收費追蹤", systemImage: "creditcard") }
            }
        }
        .navigationTitle("MusicTeacherStudio")
        .sheet(isPresented: $showStudentEditor) {
            NavigationStack { StudentEditorView() }
        }
        .sheet(isPresented: $showLessonEditor) {
            NavigationStack { LessonEditorView() }
        }
    }

    private func student(for id: UUID) -> Student? {
        students.first { $0.id == id }
    }
}

private struct TodayLessonRow: View {
    @Bindable var lesson: Lesson
    let student: Student?
    let attendance: AttendanceService

    var body: some View {
        NavigationLink {
            LessonNoteView(lesson: lesson)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(student?.name ?? "未知學生").font(.headline)
                    Spacer()
                    Text(DateFormatterUtility.timeString(lesson.scheduledStart))
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                Text(lesson.status.displayName)
                    .font(.caption)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button { attendance.markAttended(lesson) } label: { Label("出席", systemImage: "checkmark") }.tint(.green)
            Button { attendance.markNoShow(lesson) }   label: { Label("缺席", systemImage: "xmark") }.tint(.orange)
            Button(role: .destructive) { attendance.markCancelled(lesson) } label: { Label("取消", systemImage: "trash") }
        }
    }
}

#Preview {
    NavigationStack { TeacherDashboardView() }
        .modelContainer(PreviewData.makeContainer())
}
