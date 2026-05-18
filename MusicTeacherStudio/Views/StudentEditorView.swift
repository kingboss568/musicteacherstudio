import SwiftUI
import SwiftData

struct StudentEditorView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    var student: Student?

    @State private var name = ""
    @State private var instrument = "鋼琴"
    @State private var level = ""
    @State private var parentName = ""
    @State private var parentContact = ""
    @State private var defaultFee = 0
    @State private var note = ""
    @State private var isActive = true

    var body: some View {
        Form {
            Section("基本資料") {
                TextField("姓名", text: $name)
                TextField("樂器", text: $instrument)
                TextField("程度（可選）", text: $level)
                TextField("家長姓名（可選）", text: $parentName)
                TextField("家長聯絡（可選）", text: $parentContact)
                HStack {
                    Text("預設課費")
                    Spacer()
                    TextField("0", value: $defaultFee, format: .number).keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing).frame(width: 100)
                }
                Toggle("啟用中", isOn: $isActive)
            }
            Section("備註") {
                TextField("備註", text: $note, axis: .vertical).lineLimit(3...)
            }
        }
        .navigationTitle(student == nil ? "新增學生" : "編輯學生")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { Button("取消") { dismiss() } }
            ToolbarItem(placement: .topBarTrailing) {
                Button("儲存") { save() }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear {
            if let s = student {
                name = s.name
                instrument = s.instrument
                level = s.level ?? ""
                parentName = s.parentName ?? ""
                parentContact = s.parentContact ?? ""
                defaultFee = s.defaultLessonFeeCents
                note = s.note ?? ""
                isActive = s.isActive
            }
        }
    }

    private func save() {
        if let s = student {
            s.name = name
            s.instrument = instrument
            s.level = level.isEmpty ? nil : level
            s.parentName = parentName.isEmpty ? nil : parentName
            s.parentContact = parentContact.isEmpty ? nil : parentContact
            s.defaultLessonFeeCents = defaultFee
            s.note = note.isEmpty ? nil : note
            s.isActive = isActive
            s.updatedAt = .now
        } else {
            let s = Student(
                name: name,
                instrument: instrument,
                level: level.isEmpty ? nil : level,
                parentName: parentName.isEmpty ? nil : parentName,
                parentContact: parentContact.isEmpty ? nil : parentContact,
                defaultLessonFeeCents: defaultFee,
                note: note.isEmpty ? nil : note,
                isActive: isActive
            )
            ctx.insert(s)
        }
        dismiss()
    }
}

#Preview {
    NavigationStack { StudentEditorView() }
        .modelContainer(PreviewData.makeContainer())
}
