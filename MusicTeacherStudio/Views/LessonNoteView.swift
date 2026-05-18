import SwiftUI
import SwiftData

/// 30-second post-lesson flow: pick status → type quick note → save.
struct LessonNoteView: View {
    @Bindable var lesson: Lesson
    @Environment(\.modelContext) private var ctx
    @Query private var students: [Student]
    @Query private var allAssignments: [Assignment]

    @State private var noteDraft = ""
    @State private var statusDraft: LessonStatus = .scheduled

    private let attendance = AttendanceService()
    private let payService = PaymentBalanceService()

    private var student: Student? { students.first { $0.id == lesson.studentID } }
    private var relatedAssignments: [Assignment] {
        allAssignments.filter { $0.lessonID == lesson.id }
    }

    var body: some View {
        Form {
            Section("學生與時間") {
                LabeledContent("學生", value: student?.name ?? "—")
                LabeledContent("時間", value: DateFormatterUtility.dateTimeString(lesson.scheduledStart))
                LabeledContent("課費", value: MoneyFormatter.string(fromCents: lesson.feeCents))
                LabeledContent("收費狀態", value: lesson.paid ? "已收" : "未收")
                    .foregroundStyle(lesson.paid ? .green : .red)
            }

            Section("出席狀態") {
                Picker("狀態", selection: $statusDraft) {
                    ForEach(LessonStatus.allCases) { s in
                        Text(s.displayName).tag(s)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("課堂筆記") {
                TextField("輸入今天課堂重點…", text: $noteDraft, axis: .vertical)
                    .lineLimit(3...8)
            }

            Section {
                Button {
                    save()
                } label: {
                    Label("儲存", systemImage: "checkmark.circle.fill").font(.headline)
                }
            }

            Section("家長訊息") {
                NavigationLink {
                    ParentMessagePreviewView(input: ParentMessageInput(
                        studentName: student?.name ?? "",
                        instrument: student?.instrument ?? "",
                        level: student?.level,
                        lessonNote: noteDraft.isEmpty ? (lesson.teacherNote ?? "") : noteDraft,
                        assignments: relatedAssignments,
                        toneHint: nil
                    ))
                } label: {
                    Label("產生家長訊息草稿", systemImage: "envelope")
                }
            }

            if !relatedAssignments.isEmpty {
                Section("關聯作業") {
                    ForEach(relatedAssignments) { a in
                        Text(a.title)
                    }
                }
            }

            Section("收費") {
                if lesson.paid {
                    Text("已收款").foregroundStyle(.green)
                } else {
                    Button {
                        let p = payService.createPayment(for: lesson, method: nil, note: nil)
                        ctx.insert(p)
                    } label: {
                        Label("標記為已收款", systemImage: "creditcard.fill")
                    }
                }
            }
        }
        .navigationTitle("課堂紀錄")
        .onAppear {
            noteDraft = lesson.teacherNote ?? ""
            statusDraft = lesson.status
        }
    }

    private func save() {
        let trimmed = noteDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        let noteToWrite: String? = trimmed.isEmpty ? nil : trimmed
        switch statusDraft {
        case .scheduled:
            lesson.status = .scheduled
            if let n = noteToWrite { attendance.updateTeacherNote(lesson, note: n) }
        case .attended:
            attendance.markAttended(lesson, note: noteToWrite)
        case .cancelled:
            attendance.markCancelled(lesson, note: noteToWrite)
        case .noShow:
            attendance.markNoShow(lesson, note: noteToWrite)
        }
    }
}

#Preview {
    let container = PreviewData.makeContainer()
    let lesson = try! container.mainContext.fetch(FetchDescriptor<Lesson>()).first!
    return NavigationStack { LessonNoteView(lesson: lesson) }
        .modelContainer(container)
}
