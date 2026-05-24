import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = StoreKitManager.shared
    @State private var selected: ProProduct = .yearly
    @State private var animateGradient = false
    private let termsURL = URL(string: "https://kingboss568.github.io/musicteacherstudio/terms")!
    private let privacyURL = URL(string: "https://kingboss568.github.io/musicteacherstudio/privacy")!

    var body: some View {
        ZStack {
            backdrop
            ScrollView {
                VStack(spacing: Brand.Space.xl) {
                    hero
                    socialProof
                    valueProps
                    planSelector
                    purchaseCTA
                    faqSection
                    smallPrint
                }
                .padding(.horizontal, Brand.Space.l)
                .padding(.bottom, Brand.Space.xxxl)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(Brand.Space.l)
            }
        }
        .task { await store.bootstrap() }
        .onAppear {
            withAnimation(.linear(duration: 14).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }

    private var backdrop: some View {
        Image("PaywallBackdrop")
            .resizable()
            .scaledToFill()
            .overlay(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.10),
                        Color(red: 0.09, green: 0.07, blue: 0.26).opacity(0.38)
                    ],
                    startPoint: animateGradient ? .top : .bottom,
                    endPoint: animateGradient ? .bottom : .top
                )
            )
            .ignoresSafeArea()
    }

    // MARK: - Sections

    private var hero: some View {
        VStack(spacing: Brand.Space.s) {
            Image(systemName: "music.note.list")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(.white)
                .padding(Brand.Space.l)
                .background(
                    Circle().fill(.white.opacity(0.15))
                        .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 1))
                )
                .padding(.top, Brand.Space.xxl)
            Text("升級 \(Brand.Strings.proName)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("把收費、作業、家長訊息與報表變成一套可交付的工作室系統。")
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
        }
    }

    private var valueProps: some View {
        VStack(spacing: Brand.Space.s) {
            ForEach(Entitlement.allCases, id: \.self) { e in
                HStack(spacing: Brand.Space.m) {
                    Image(systemName: e.symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(.white.opacity(0.2)))
                        .foregroundStyle(.white)
                    Text(e.displayName)
                        .font(Brand.Font.body)
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                }
                .padding(.vertical, 6)
            }
        }
        .padding(Brand.Space.l)
        .background(
            RoundedRectangle(cornerRadius: Brand.Radius.xl, style: .continuous)
                .fill(.white.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: Brand.Radius.xl).stroke(.white.opacity(0.3), lineWidth: 1))
        )
    }

    private var socialProof: some View {
        VStack(spacing: Brand.Space.m) {
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color(red: 1, green: 0.83, blue: 0.27))
                        .font(.system(size: 13))
                }
                Text("老師們的心得").font(Brand.Font.captionEmphasis).foregroundStyle(.white.opacity(0.85))
            }
            HStack(spacing: 10) {
                quote("「以前每週末整理收費要兩小時，現在 10 分鐘搞定。」", "鋼琴 · 林老師")
                quote("「家長訊息再也不用我從零打字。」", "小提琴 · 王老師")
            }
        }
    }

    private func quote(_ text: String, _ author: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\u{201C}").font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
                .frame(height: 10, alignment: .top)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Text(author).font(.system(size: 11)).foregroundStyle(.white.opacity(0.7))
        }
        .padding(Brand.Space.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Brand.Radius.m)
                .fill(.white.opacity(0.10))
                .overlay(RoundedRectangle(cornerRadius: Brand.Radius.m).stroke(.white.opacity(0.18)))
        )
    }

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: Brand.Space.s) {
            Text("常見問題").font(Brand.Font.title2).foregroundStyle(.white)
            ForEach(PaywallFAQ.all, id: \.question) { item in
                FAQRow(question: item.question, answer: item.answer)
            }
        }
    }

    private var planSelector: some View {
        VStack(spacing: Brand.Space.m) {
            ForEach(ProProduct.allCases) { plan in
                PlanRow(
                    plan: plan,
                    product: store.product(for: plan),
                    isSelected: selected == plan
                ) {
                    selected = plan
                    UISelectionFeedbackGenerator().selectionChanged()
                }
            }
        }
    }

    private var purchaseCTA: some View {
        VStack(spacing: Brand.Space.s) {
            Button {
                Task {
                    if let p = store.product(for: selected) { await store.purchase(p) }
                }
            } label: {
                HStack {
                    if store.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(selected == .lifetime ? "永久解鎖 Pro" : "開始 7 天免費試用")
                    }
                }
            }
            .buttonStyle(GoldButtonStyle())
            .disabled(store.isLoading)

            Button("已購買？還原購買") { Task { await store.restore() } }
                .font(Brand.Font.caption)
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    private var smallPrint: some View {
        VStack(spacing: 6) {
            Text("訂閱會自動續訂，可隨時於 App Store 取消。")
            Text("月訂閱含 7 天免費試用；所有付費功能都在 App 內解鎖。")
            HStack(spacing: 10) {
                Link("使用條款", destination: termsURL)
                Text("·")
                Link("隱私政策", destination: privacyURL)
            }
        }
        .font(.system(size: 11))
        .foregroundStyle(.white.opacity(0.7))
        .multilineTextAlignment(.center)
    }
}

struct PaywallFAQ: Equatable {
    let question: String
    let answer: String

    static let all: [PaywallFAQ] = [
        PaywallFAQ(
            question: "試用期可以取消嗎？",
            answer: "可以。7 天試用期內隨時於 App Store 訂閱項目取消，不會被扣款。"
        ),
        PaywallFAQ(
            question: "買月訂閱跟年訂閱差別？",
            answer: "年訂閱省 31%。Pro 功能完全相同；如果你想長期使用，建議直接年訂閱或終身版。"
        ),
        PaywallFAQ(
            question: "終身版包含哪些內容？",
            answer: "終身版一次付清，解鎖本版本所有 Pro 功能，不會自動續訂。"
        ),
        PaywallFAQ(
            question: "我的學生資料安全嗎？",
            answer: "完全本機儲存。我們沒有伺服器、沒有後端、不會看到也不會收集你的資料。"
        ),
        PaywallFAQ(
            question: "我換手機怎麼辦？",
            answer: "目前請使用 Pro 的 CSV 匯出與本機備份包手動保存資料，再在新裝置匯入或留存。"
        )
    ]
}

private struct FAQRow: View {
    let question: String
    let answer: String
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                Haptics.select()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    expanded.toggle()
                }
            } label: {
                HStack {
                    Text(question).font(Brand.Font.bodyEmphasis).foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .buttonStyle(.plain)
            if expanded {
                Text(answer)
                    .font(Brand.Font.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(Brand.Space.m)
        .background(
            RoundedRectangle(cornerRadius: Brand.Radius.m).fill(.white.opacity(0.08))
        )
    }
}

private struct PlanRow: View {
    let plan: ProProduct
    let product: Product?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: Brand.Space.m) {
                ZStack {
                    Circle().stroke(.white.opacity(0.55), lineWidth: 2).frame(width: 22, height: 22)
                    if isSelected {
                        Circle().fill(.white).frame(width: 12, height: 12)
                    }
                }
                .padding(.top, 4)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(plan.headline).font(Brand.Font.title2).foregroundStyle(.white)
                        if let b = plan.badge {
                            Text(b)
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Capsule().fill(Brand.goldGradient))
                                .foregroundStyle(.white)
                        }
                    }
                    Text(plan.subhead).font(Brand.Font.caption).foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product?.displayPrice ?? plan.fallbackPrice)
                        .font(Brand.Font.bodyEmphasis)
                        .foregroundStyle(.white)
                    if plan == .yearly {
                        Text("≈ NT$82.5 / 月").font(.system(size: 11)).foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
            .padding(Brand.Space.l)
            .background(
                RoundedRectangle(cornerRadius: Brand.Radius.l, style: .continuous)
                    .fill(.white.opacity(isSelected ? 0.22 : 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: Brand.Radius.l)
                            .stroke(isSelected ? Color.white : Color.white.opacity(0.25), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallView()
}
