import SwiftUI
import SwiftData

struct StudentListView: View {
    @EnvironmentObject private var store: StoreKitManager
    @Query(sort: \Student.name) private var students: [Student]
    @Query private var lessons: [Lesson]
    @State private var searchText = ""
    @State private var showInactive = false
    @State private var showStudentEditor = false
    @State private var showPaywall = false

    private let payService = PaymentBalanceService()

    private var filtered: [Student] {
        students.filter { s in
            (showInactive || s.isActive)
                && (searchText.isEmpty
                    || s.name.localizedCaseInsensitiveContains(searchText)
                    || s.instrument.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        List {
            ForEach(filtered) { student in
                NavigationLink {
                    StudentDetailView(student: student)
                } label: {
                    StudentRow(student: student,
                               balanceCents: payService.outstandingBalanceCents(for: student.id, lessons: lessons),
                               lastLessonDate: lessons.filter { $0.studentID == student.id }
                                   .map(\.scheduledStart).max())
                }
            }
        }
        .navigationTitle("學生")
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showInactive.toggle()
                } label: {
                    Label(showInactive ? "只看啟用" : "含停用",
                          systemImage: showInactive ? "person.crop.circle.badge.checkmark" : "line.3.horizontal.decrease.circle")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if !store.isPro && students.count >= FreeLimits.maxStudents {
                        showPaywall = true
                        UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    } else {
                        showStudentEditor = true
                    }
                } label: { Image(systemName: "plus") }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !store.isPro {
                HStack {
                    Image(systemName: "person.3.fill").foregroundStyle(Brand.primary)
                    Text("免費版上限 \(FreeLimits.maxStudents) 位學生（目前 \(students.count)）")
                        .font(Brand.Font.caption)
                    Spacer()
                    Button("升級") { showPaywall = true }
                        .font(Brand.Font.captionEmphasis)
                        .foregroundStyle(Brand.primary)
                }
                .padding(.horizontal, Brand.Space.l)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
        }
        .sheet(isPresented: $showStudentEditor) {
            NavigationStack { StudentEditorView() }
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }
}

private struct StudentRow: View {
    let student: Student
    let balanceCents: Int
    let lastLessonDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(student.name).font(.headline)
                if !student.isActive {
                    Text("停用").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if balanceCents > 0 {
                    Text(MoneyFormatter.string(fromCents: balanceCents))
                        .font(.subheadline).foregroundStyle(.red)
                }
            }
            HStack(spacing: 8) {
                Text(student.instrument)
                if let level = student.level { Text("・\(level)") }
                if let last = lastLessonDate {
                    Spacer()
                    Text("最近：\(DateFormatterUtility.dateString(last))")
                }
            }
            .font(.caption).foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack { StudentListView() }
        .modelContainer(PreviewData.makeContainer())
}
