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
        Group {
            if students.isEmpty {
                EmptyStateView(
                    icon: "person.2",
                    title: "還沒有任何學生",
                    subtitle: "點右上角 + 來新增第一位學生，\n或從 CSV 匯入（Pro）。",
                    actionTitle: "新增第一位學生",
                    action: {
                        Haptics.light()
                        showStudentEditor = true
                    },
                    assetName: "EmptyStudents"
                )
            } else {
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
                .listStyle(.plain)
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
        HStack(spacing: Brand.Space.m) {
            StudentAvatar(name: student.name, instrument: student.instrument, size: 48)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(student.name).font(Brand.Font.bodyEmphasis).foregroundStyle(Brand.ink)
                    if !student.isActive {
                        Text("停用")
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(Color.gray.opacity(0.18)))
                            .foregroundStyle(.secondary)
                    }
                }
                HStack(spacing: 6) {
                    Text(student.instrument)
                    if let level = student.level { Text("・\(level)") }
                    if let last = lastLessonDate {
                        Text("・最近 \(DateFormatterUtility.dateString(last))")
                    }
                }
                .font(Brand.Font.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            if balanceCents > 0 {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(MoneyFormatter.string(fromCents: balanceCents))
                        .font(Brand.Font.bodyEmphasis).foregroundStyle(Brand.danger)
                    Text("待收").font(.system(size: 10)).foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack { StudentListView() }
        .modelContainer(PreviewData.makeContainer())
}
