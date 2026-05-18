import SwiftUI
import SwiftData
import UIKit

/// Pro 功能：選擇多位學生，套用同一段家長訊息模板，批次複製。
struct BatchMessageView: View {
    @EnvironmentObject private var store: StoreKitManager
    @Query(sort: \Student.name) private var students: [Student]
    @State private var selectedIDs: Set<UUID> = []
    @State private var template: String = "親愛的家長您好，本週課程順利完成，感謝您持續支持孩子的練習。"
    @State private var showPaywall = false
    @State private var generated: [(student: Student, text: String)] = []

    var body: some View {
        ZStack {
            Brand.surface.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: Brand.Space.l) {
                    if !store.isPro { proHint }
                    BrandCard {
                        VStack(alignment: .leading, spacing: Brand.Space.s) {
                            BrandSectionHeader(title: "訊息模板",
                                               subtitle: "可使用 {{name}} 自動帶入學生姓名")
                            TextEditor(text: $template)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.tertiarySystemFill)))
                        }
                    }
                    BrandCard {
                        VStack(alignment: .leading, spacing: Brand.Space.s) {
                            BrandSectionHeader(title: "選擇學生",
                                               subtitle: "已選 \(selectedIDs.count) 位")
                            ForEach(students) { s in
                                Button {
                                    if selectedIDs.contains(s.id) { selectedIDs.remove(s.id) }
                                    else { selectedIDs.insert(s.id) }
                                    UISelectionFeedbackGenerator().selectionChanged()
                                } label: {
                                    HStack {
                                        Image(systemName: selectedIDs.contains(s.id) ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(selectedIDs.contains(s.id) ? Brand.primary : .secondary)
                                        Text(s.name)
                                        Spacer()
                                        Text(s.instrument).font(Brand.Font.caption).foregroundStyle(.secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.vertical, 6)
                            }
                        }
                    }
                    Button {
                        guard store.isPro else { showPaywall = true; return }
                        generate()
                    } label: {
                        Label("產生並複製所有訊息", systemImage: "doc.on.doc.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(selectedIDs.isEmpty)

                    if !generated.isEmpty {
                        BrandCard {
                            VStack(alignment: .leading, spacing: Brand.Space.s) {
                                BrandSectionHeader(title: "預覽（已複製到剪貼簿）")
                                ForEach(generated, id: \.student.id) { item in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.student.name).font(Brand.Font.bodyEmphasis)
                                        Text(item.text).font(Brand.Font.body)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 6)
                                    BrandDivider()
                                }
                            }
                        }
                    }
                }
                .padding(Brand.Space.l)
            }
        }
        .proLock(!store.isPro) { showPaywall = true }
        .navigationTitle("批次家長訊息")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private var proHint: some View {
        HStack(spacing: Brand.Space.m) {
            Image(systemName: "envelope.badge.fill")
                .font(.title2).foregroundStyle(.white)
                .padding(10).background(Circle().fill(Brand.goldGradient))
            VStack(alignment: .leading) {
                Text("批次家長訊息").font(Brand.Font.bodyEmphasis)
                Text("一次選 20 位學生，套用模板自動置換姓名，省下 1 小時。")
                    .font(Brand.Font.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button("解鎖") { showPaywall = true }.buttonStyle(SecondaryButtonStyle()).frame(width: 90)
        }
        .padding(Brand.Space.m)
        .background(RoundedRectangle(cornerRadius: Brand.Radius.m).fill(Brand.accent.opacity(0.08)))
    }

    private func generate() {
        let selected = students.filter { selectedIDs.contains($0.id) }
        let items = selected.map { s in
            (student: s, text: template.replacingOccurrences(of: "{{name}}", with: s.name))
        }
        generated = items
        UIPasteboard.general.string = items.map { "【\($0.student.name)】\n\($0.text)" }.joined(separator: "\n\n")
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
