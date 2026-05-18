import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var pageIndex = 0
    @State private var showPaywall = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "OnboardingHero1", icon: "music.note.list", tint: Brand.primary,
            title: Brand.Strings.productName,
            subtitle: Brand.Strings.tagline,
            body: "私人音樂老師專屬。\n學生、課表、收費、作業、家長訊息，一頁搞定。"
        ),
        OnboardingPage(
            imageName: "OnboardingCharts", icon: "stopwatch.fill", tint: Brand.success,
            title: "30 秒完成課後紀錄",
            subtitle: "減少行政，留給音樂",
            body: "點 → 選 → 寫 → 存。\n出席、筆記、收費、AI 家長訊息一氣呵成。"
        ),
        OnboardingPage(
            imageName: "OnboardingAI", icon: "sparkles", tint: Brand.accent,
            title: "AI 家長訊息 + 學習摘要",
            subtitle: "離線優先，老師永遠可以編輯",
            body: "AI 只產草稿，從不自動發送。\n不評斷學生天分，只描述觀察到的進展。"
        ),
        OnboardingPage(
            imageName: "OnboardingPro", icon: "crown.fill", tint: Brand.warning,
            title: "升級 Pro，把整個工作室搬上手機",
            subtitle: "無限學生 · 批次訊息 · 進階報表",
            body: "免費 7 天試用，隨時取消。"
        )
    ]

    var body: some View {
        ZStack {
            Brand.surface.ignoresSafeArea()
            VStack {
                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { idx, page in
                        OnboardingPageView(page: page).tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == pageIndex ? Brand.primary : Brand.primary.opacity(0.2))
                            .frame(width: i == pageIndex ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: pageIndex)
                    }
                }
                .padding(.bottom, Brand.Space.l)

                VStack(spacing: Brand.Space.s) {
                    if pageIndex == pages.count - 1 {
                        Button("開始 7 天免費試用") { showPaywall = true }
                            .buttonStyle(GoldButtonStyle())
                        Button("先用免費版") { finish() }
                            .font(Brand.Font.captionEmphasis)
                            .foregroundStyle(.secondary)
                    } else {
                        Button("下一步") {
                            withAnimation { pageIndex += 1 }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        Button("跳過") { finish() }
                            .font(Brand.Font.captionEmphasis)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, Brand.Space.xl)
                .padding(.bottom, Brand.Space.l)
            }
        }
        .sheet(isPresented: $showPaywall, onDismiss: { finish() }) {
            PaywallView()
        }
    }

    private func finish() {
        withAnimation { hasSeenOnboarding = true }
    }
}

struct OnboardingPage {
    let imageName: String
    let icon: String
    let tint: Color
    let title: String
    let subtitle: String
    let body: String
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    var body: some View {
        VStack(spacing: Brand.Space.xl) {
            Spacer()
            ZStack {
                Circle().fill(page.tint.opacity(0.12)).frame(width: 220, height: 220)
                Image(page.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 230, height: 230)
                    .accessibilityHidden(true)
            }
            VStack(spacing: Brand.Space.s) {
                Text(page.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Brand.ink)
                Text(page.subtitle)
                    .font(Brand.Font.title2)
                    .foregroundStyle(page.tint)
                Text(page.body)
                    .font(Brand.Font.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Brand.Space.xl)
            }
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
