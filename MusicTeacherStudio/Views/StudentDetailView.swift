import SwiftUI
import SwiftData
import UIKit

struct StudentDetailView: View {
    @Environment(\.modelContext) private var ctx
    @EnvironmentObject private var store: StoreKitManager
    @Bindable var student: Student

    @Query private var allLessons: [Lesson]
    @Query private var allAssignments: [Assignment]
    @Query private var allRecordings: [PracticeRecording]
    @Query private var allPayments: [PaymentRecord]

    @State private var showEdit = false
    @State private var showAddLesson = false
    @State private var showAddAssignment = false
    @State private var showAddPayment = false
    @State private var showImporter = false
    @State private var showPDF: URL?
    @State private var pdfError: String?

    private let payService = PaymentBalanceService()
    private let recService = PracticeRecordingService()
    private var pdfRenderer: StudentProgressReportRenderer {
        StudentProgressReportRenderer(
            includeWatermark: !store.hasEntitlement(.removeWatermark),
            bilingual: store.hasEntitlement(.bilingualPDF)
        )
    }

    private var lessons: [Lesson] {
        allLessons.filter { $0.studentID == student.id }
            .sorted { $0.scheduledStart > $1.scheduledStart }
    }
    private var assignments: [Assignment] {
        allAssignments.filter { $0.studentID == student.id }
    }
    private var recordings: [PracticeRecording] {
        allRecordings.filter { $0.studentID == student.id }
            .sorted { $0.recordedAt > $1.recordedAt }
    }
    private var payments: [PaymentRecord] {
        allPayments.filter { $0.studentID == student.id }
            .sorted { $0.paidAt > $1.paidAt }
    }
    private var balance: Int {
        payService.outstandingBalanceCents(for: student.id, lessons: allLessons)
    }

    var body: some View {
        List {
            Section("基本資料") {
                LabeledContent("姓名", value: student.name)
                LabeledContent("樂器", value: student.instrument)
                if let level = student.level { LabeledContent("程度", value: level) }
                if let p = student.parentName { LabeledContent("家長", value: p) }
                if let c = student.parentContact { LabeledContent("聯絡", value: c) }
                LabeledContent("預設課費", value: MoneyFormatter.string(fromCents: student.defaultLessonFeeCents))
                LabeledContent("欠款", value: MoneyFormatter.string(fromCents: balance))
                    .foregroundStyle(balance > 0 ? .red : .primary)
                if let note = student.note { Text(note).foregroundStyle(.secondary) }
            }

            Section("最近課程") {
                if lessons.isEmpty { Text("無").foregroundStyle(.secondary) }
                ForEach(lessons.prefix(8)) { lesson in
                    NavigationLink {
                        LessonNoteView(lesson: lesson)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(DateFormatterUtility.dateTimeString(lesson.scheduledStart))
                                Text(lesson.status.displayName).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(MoneyFormatter.string(fromCents: lesson.feeCents))
                                .foregroundStyle(lesson.paid ? .green : .secondary)
                        }
                    }
                }
                Button { showAddLesson = true } label: { Label("新增課程", systemImage: "plus") }
            }

            Section("作業") {
                if assignments.isEmpty { Text("無").foregroundStyle(.secondary) }
                ForEach(assignments) { a in
                    VStack(alignment: .leading) {
                        Text(a.title)
                        Text("\(a.status.displayName)\(a.dueDate.map { "・\(DateFormatterUtility.dateString($0))" } ?? "")")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                Button { showAddAssignment = true } label: { Label("新增作業", systemImage: "plus") }
            }

            Section("錄音") {
                if recordings.isEmpty { Text("無").foregroundStyle(.secondary) }
                ForEach(recordings) { r in
                    VStack(alignment: .leading) {
                        Text(r.originalFileName ?? "錄音")
                        Text(DateFormatterUtility.dateTimeString(r.recordedAt))
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                Button { showImporter = true } label: { Label("匯入錄音", systemImage: "waveform.badge.plus") }
            }

            Section("付款紀錄") {
                if payments.isEmpty { Text("無").foregroundStyle(.secondary) }
                ForEach(payments) { p in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(MoneyFormatter.string(fromCents: p.amountCents))
                            Text("\(DateFormatterUtility.dateString(p.paidAt))\(p.method.map { "・\($0)" } ?? "")")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                Button { showAddPayment = true } label: { Label("新增付款", systemImage: "plus") }
            }

            Section("AI 助理（草稿）") {
                NavigationLink {
                    LessonSummaryView(input: LessonSummaryInput(
                        student: student,
                        recentLessons: Array(lessons.prefix(4)),
                        recentAssignments: assignments
                    ))
                } label: {
                    Label("產生學習進度摘要", systemImage: "sparkles")
                }
                if let mostRecent = lessons.first {
                    NavigationLink {
                        ParentMessagePreviewView(input: ParentMessageInput(
                            studentName: student.name,
                            instrument: student.instrument,
                            level: student.level,
                            lessonNote: mostRecent.teacherNote ?? "",
                            assignments: assignments.filter { $0.lessonID == mostRecent.id },
                            toneHint: nil
                        ))
                    } label: {
                        Label("產生家長訊息草稿", systemImage: "envelope")
                    }
                }
            }

            Section("匯出") {
                Button {
                    do {
                        showPDF = try pdfRenderer.renderProgressReport(
                            student: student, lessons: lessons,
                            assignments: assignments, recordings: recordings)
                    } catch {
                        pdfError = error.localizedDescription
                    }
                } label: {
                    Label("匯出學習歷程 PDF", systemImage: "doc.richtext")
                }
            }
        }
        .navigationTitle(student.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("編輯") { showEdit = true }
            }
        }
        .sheet(isPresented: $showEdit) {
            NavigationStack { StudentEditorView(student: student) }
        }
        .sheet(isPresented: $showAddLesson) {
            NavigationStack { LessonEditorView(presetStudentID: student.id) }
        }
        .sheet(isPresented: $showAddAssignment) {
            NavigationStack { AssignmentEditorView(presetStudentID: student.id) }
        }
        .sheet(isPresented: $showAddPayment) {
            NavigationStack { PaymentEditorView(student: student) }
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.audio, .mp3, .wav],
            allowsMultipleSelection: false
        ) { result in
            guard case .success(let urls) = result, let url = urls.first else { return }
            do {
                let rec = try recService.importRecording(sourceURL: url, studentID: student.id)
                ctx.insert(rec)
            } catch {
                pdfError = "匯入錄音失敗：\(error)"
            }
        }
        .sheet(item: $showPDF) { url in
            PDFShareView(url: url)
        }
        .alert("錯誤", isPresented: .constant(pdfError != nil), actions: {
            Button("好", role: .cancel) { pdfError = nil }
        }, message: { Text(pdfError ?? "") })
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

private struct PDFShareView: View {
    let url: URL
    var body: some View {
        VStack {
            ShareLink(item: url) {
                Label("分享 PDF", systemImage: "square.and.arrow.up")
                    .font(.title3).padding()
            }
            Text(url.lastPathComponent).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        StudentDetailView(student: try! ModelContext(PreviewData.makeContainer())
            .fetch(FetchDescriptor<Student>()).first!)
    }
    .modelContainer(PreviewData.makeContainer())
}
