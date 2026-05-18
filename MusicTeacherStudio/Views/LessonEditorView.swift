import SwiftUI
import SwiftData

struct LessonEditorView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Student.name) private var students: [Student]

    var presetStudentID: UUID? = nil

    @State private var selectedStudentID: UUID?
    @State private var start: Date = .now
    @State private var durationMinutes: Int = 60
    @State private var feeCents: Int = 800

    private let scheduler = LessonScheduler()

    var body: some View {
        Form {
            Section("學生") {
                Picker("學生", selection: $selectedStudentID) {
                    Text("（請選擇）").tag(UUID?.none)
                    ForEach(students) { s in
                        Text(s.name).tag(Optional(s.id))
                    }
                }
            }
            Section("時間") {
                DatePicker("開始", selection: $start)
                Stepper(value: $durationMinutes, in: 15...180, step: 15) {
                    HStack { Text("時長"); Spacer(); Text("\(durationMinutes) 分") }
                }
            }
            Section("費用") {
                HStack {
                    Text("課費")
                    Spacer()
                    TextField("0", value: $feeCents, format: .number).keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing).frame(width: 100)
                }
            }
        }
        .navigationTitle("新增課程")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { Button("取消") { dismiss() } }
            ToolbarItem(placement: .topBarTrailing) {
                Button("儲存") { save() }
                    .disabled(selectedStudentID == nil)
            }
        }
        .onAppear {
            if let preset = presetStudentID {
                selectedStudentID = preset
                if let s = students.first(where: { $0.id == preset }) {
                    feeCents = s.defaultLessonFeeCents > 0 ? s.defaultLessonFeeCents : feeCents
                }
            }
        }
    }

    private func save() {
        guard let sid = selectedStudentID else { return }
        let lesson = scheduler.createOneOffLesson(
            studentID: sid, start: start,
            durationMinutes: durationMinutes, feeCents: feeCents
        )
        ctx.insert(lesson)
        dismiss()
    }
}

#Preview {
    NavigationStack { LessonEditorView() }
        .modelContainer(PreviewData.makeContainer())
}
