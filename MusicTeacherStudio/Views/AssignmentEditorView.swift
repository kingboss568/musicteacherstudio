import SwiftUI
import SwiftData

struct AssignmentEditorView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Student.name) private var students: [Student]
    @Query private var lessons: [Lesson]

    var presetStudentID: UUID? = nil
    var assignment: Assignment? = nil

    @State private var selectedStudentID: UUID?
    @State private var title: String = ""
    @State private var instruction: String = ""
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
    @State private var linkedLessonID: UUID?
    @State private var status: AssignmentStatus = .open

    private let svc = AssignmentService()

    private var lessonsForStudent: [Lesson] {
        guard let sid = selectedStudentID else { return [] }
        return lessons.filter { $0.studentID == sid }.sorted { $0.scheduledStart > $1.scheduledStart }
    }

    var body: some View {
        Form {
            Section("學生") {
                Picker("學生", selection: $selectedStudentID) {
                    Text("（請選擇）").tag(UUID?.none)
                    ForEach(students) { s in Text(s.name).tag(Optional(s.id)) }
                }
            }
            Section("內容") {
                TextField("標題", text: $title)
                TextField("指示", text: $instruction, axis: .vertical).lineLimit(3...)
            }
            Section("到期日") {
                Toggle("設定到期日", isOn: $hasDueDate)
                if hasDueDate {
                    DatePicker("到期", selection: $dueDate, displayedComponents: .date)
                }
            }
            Section("關聯課程（可選）") {
                Picker("課程", selection: $linkedLessonID) {
                    Text("無").tag(UUID?.none)
                    ForEach(lessonsForStudent) { l in
                        Text(DateFormatterUtility.dateTimeString(l.scheduledStart)).tag(Optional(l.id))
                    }
                }
            }
            Section("狀態") {
                Picker("狀態", selection: $status) {
                    ForEach(AssignmentStatus.allCases) { Text($0.displayName).tag($0) }
                }
            }
        }
        .navigationTitle(assignment == nil ? "新增作業" : "編輯作業")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { Button("取消") { dismiss() } }
            ToolbarItem(placement: .topBarTrailing) {
                Button("儲存") { save() }
                    .disabled(selectedStudentID == nil || title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear {
            if let a = assignment {
                selectedStudentID = a.studentID
                title = a.title
                instruction = a.instruction
                hasDueDate = a.dueDate != nil
                if let d = a.dueDate { dueDate = d }
                linkedLessonID = a.lessonID
                status = a.status
            } else if let preset = presetStudentID {
                selectedStudentID = preset
            }
        }
    }

    private func save() {
        guard let sid = selectedStudentID else { return }
        let due = hasDueDate ? dueDate : nil
        if let a = assignment {
            a.studentID = sid
            a.title = title
            a.instruction = instruction
            a.dueDate = due
            a.lessonID = linkedLessonID
            a.status = status
            a.updatedAt = .now
        } else {
            let a = svc.createAssignment(
                studentID: sid, lessonID: linkedLessonID,
                title: title, instruction: instruction, dueDate: due
            )
            a.status = status
            ctx.insert(a)
        }
        dismiss()
    }
}

#Preview {
    NavigationStack { AssignmentEditorView() }
        .modelContainer(PreviewData.makeContainer())
}
