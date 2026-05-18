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
                    valueProps
                    planSelector
                    purchaseCTA
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
