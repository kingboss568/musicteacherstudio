import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: StoreKitManager
    @Query private var students: [Student]
    @Query private var lessons: [Lesson]
    @Query private var assignments: [Assignment]
    @Query private var payments: [PaymentRecord]
    @State private var showPaywall = false
    @State private var exportedURL: URL?
    @State private var exportError: String?

    private let csvService = CSVExportService()
    private let termsURL = URL(string: "https://kingboss568.github.io/musicteacherstudio/terms")!
    private let privacyURL = URL(string: "https://kingboss568.github.io/musicteacherstudio/privacy")!
    private let supportURL = URL(string: "https://kingboss568.github.io/musicteacherstudio/support")!

    var body: some View {
        ScrollView {
            VStack(spacing: Brand.Space.l) {
                statusCard
                section("資料", icon: "externaldrive.fill") {
                    settingRow(icon: "tablecells.fill", title: "匯出所有資料 CSV",
                               trailing: store.isPro ? nil : "Pro") {
                        if !store.isPro { showPaywall = true; return }
                        exportAllData()
                    }
                    settingRow(icon: "externaldrive.fill", title: "本機備份包",
                               trailing: store.isPro ? "可匯出" : "Pro") {
                        if !store.isPro { showPaywall = true }
                        else { exportAllData() }
                    }
                }
                section("Pro 與訂閱", icon: "crown.fill") {
                    if store.isPro {
                        Label("已是 Pro 用戶", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Brand.success)
                            .padding(.vertical, 6)
                    } else {
                        Button("升級 Pro") { showPaywall = true }
                            .buttonStyle(GoldButtonStyle())
                    }
                    settingRow(icon: "arrow.clockwise", title: "還原購買") {
                        Task { await store.restore() }
                    }
                    settingRow(icon: "person.crop.circle", title: "管理訂閱") {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                section("關於", icon: "info.circle.fill") {
                    settingRow(icon: "questionmark.circle.fill", title: "支援頁") {
                        UIApplication.shared.open(supportURL)
                    }
                    settingRow(icon: "doc.text.fill", title: "使用條款") {
                        UIApplication.shared.open(termsURL)
                    }
                    settingRow(icon: "hand.raised.fill", title: "隱私政策") {
                        UIApplication.shared.open(privacyURL)
                    }
                    HStack {
                        Text("版本").font(Brand.Font.body)
                        Spacer()
                        Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                            .foregroundStyle(.secondary)
                            .font(Brand.Font.caption)
                    }
                    .padding(.vertical, 6)
                }
            }
            .padding(Brand.Space.l)
        }
        .background(Brand.surface.ignoresSafeArea())
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .sheet(item: $exportedURL) { url in
            VStack(spacing: Brand.Space.l) {
                ShareLink(item: url) {
                    Label("分享 / 儲存 CSV", systemImage: "square.and.arrow.up")
                }.buttonStyle(PrimaryButtonStyle())
                Text(url.lastPathComponent).font(Brand.Font.caption).foregroundStyle(.secondary)
            }
            .padding(Brand.Space.xl)
        }
        .alert("匯出失敗", isPresented: .constant(exportError != nil), actions: {
            Button("好", role: .cancel) { exportError = nil }
        }, message: { Text(exportError ?? "") })
    }

    private var statusCard: some View {
        BrandCard(background: AnyShapeStyle(store.isPro ? Brand.goldGradient : Brand.heroGradient)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.isPro ? Brand.Strings.proName : Brand.Strings.productName)
                        .font(Brand.Font.title)
                        .foregroundStyle(.white)
                    Text(store.isPro ? "已解鎖全部 Pro 工作室功能" : Brand.Strings.tagline)
                        .font(Brand.Font.caption)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
                Image(systemName: store.isPro ? "crown.fill" : "music.note.list")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, icon: String,
                                        @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Brand.Space.s) {
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(Brand.primary)
                Text(title).font(Brand.Font.title2)
            }
            .padding(.horizontal, Brand.Space.s)
            BrandCard {
                VStack(alignment: .leading, spacing: 6) { content() }
            }
        }
    }

    private func settingRow(icon: String, title: String,
                            trailing: String? = nil,
                            action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon).foregroundStyle(Brand.primary).frame(width: 28)
                Text(title).font(Brand.Font.body).foregroundStyle(Brand.ink)
                Spacer()
                if let t = trailing {
                    if t == "Pro" {
                        ProBadge()
                    } else {
                        Text(t).font(Brand.Font.caption).foregroundStyle(.secondary)
                    }
                }
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private func exportAllData() {
        do {
            exportedURL = try csvService.exportAll(
                students: students, lessons: lessons,
                assignments: assignments, payments: payments
            )
        } catch {
            exportError = error.localizedDescription
        }
    }
}
