import SwiftUI
import SwiftData

struct PaymentTrackerView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: \Student.name) private var students: [Student]
    @Query private var lessons: [Lesson]
    @Query private var payments: [PaymentRecord]

    private let payService = PaymentBalanceService()

    private var balances: [(Student, Int)] {
        students.map { s in (s, payService.outstandingBalanceCents(for: s.id, lessons: lessons)) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    var body: some View {
        List {
            Section("欠款") {
                if balances.isEmpty { Text("目前沒有欠款 🎉").foregroundStyle(.secondary) }
                ForEach(balances, id: \.0.id) { (s, b) in
                    NavigationLink {
                        UnpaidLessonsView(student: s)
                    } label: {
                        HStack {
                            Text(s.name)
                            Spacer()
                            Text(MoneyFormatter.string(fromCents: b)).foregroundStyle(.red)
                        }
                    }
                }
            }
            Section("近期付款紀錄") {
                let recent = payments.sorted { $0.paidAt > $1.paidAt }.prefix(20)
                if recent.isEmpty { Text("無").foregroundStyle(.secondary) }
                ForEach(Array(recent), id: \.id) { p in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(students.first { $0.id == p.studentID }?.name ?? "—")
                            Text("\(DateFormatterUtility.dateString(p.paidAt))\(p.method.map { "・\($0)" } ?? "")")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(MoneyFormatter.string(fromCents: p.amountCents))
                    }
                }
            }
        }
        .navigationTitle("收費追蹤")
    }
}

private struct UnpaidLessonsView: View {
    let student: Student
    @Environment(\.modelContext) private var ctx
    @Query private var allLessons: [Lesson]
    @State private var showAddPayment = false

    private let payService = PaymentBalanceService()

    private var unpaid: [Lesson] {
        payService.chargeableUnpaidLessons(for: student.id, lessons: allLessons)
            .sorted { $0.scheduledStart < $1.scheduledStart }
    }

    var body: some View {
        List {
            Section("未付款課程") {
                if unpaid.isEmpty {
                    Text("無").foregroundStyle(.secondary)
                }
                ForEach(unpaid) { lesson in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(DateFormatterUtility.dateTimeString(lesson.scheduledStart))
                            Text(lesson.status.displayName).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(MoneyFormatter.string(fromCents: lesson.feeCents))
                        Button("已收") {
                            let p = payService.createPayment(for: lesson, method: nil, note: nil)
                            ctx.insert(p)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            Section {
                Button { showAddPayment = true } label: { Label("新增付款", systemImage: "plus") }
            }
        }
        .navigationTitle(student.name)
        .sheet(isPresented: $showAddPayment) {
            NavigationStack { PaymentEditorView(student: student) }
        }
    }
}

struct PaymentEditorView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    let student: Student

    @State private var amountCents: Int = 0
    @State private var method: String = ""
    @State private var note: String = ""
    @State private var paidAt: Date = .now

    var body: some View {
        Form {
            Section("金額") {
                HStack {
                    Text("金額")
                    Spacer()
                    TextField("0", value: $amountCents, format: .number).keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing).frame(width: 120)
                }
            }
            Section("付款資訊") {
                TextField("方式（現金 / 轉帳 ...）", text: $method)
                DatePicker("日期", selection: $paidAt, displayedComponents: .date)
                TextField("備註", text: $note, axis: .vertical).lineLimit(2...)
            }
        }
        .navigationTitle("\(student.name) 新增付款")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { Button("取消") { dismiss() } }
            ToolbarItem(placement: .topBarTrailing) {
                Button("儲存") {
                    let p = PaymentRecord(
                        studentID: student.id, lessonID: nil,
                        amountCents: amountCents, paidAt: paidAt,
                        method: method.isEmpty ? nil : method,
                        note: note.isEmpty ? nil : note
                    )
                    ctx.insert(p)
                    dismiss()
                }
                .disabled(amountCents <= 0)
            }
        }
    }
}

#Preview {
    NavigationStack { PaymentTrackerView() }
        .modelContainer(PreviewData.makeContainer())
}
