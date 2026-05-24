import SwiftUI

// MARK: - Card

struct BrandCard<Content: View>: View {
    var padding: CGFloat = Brand.Space.l
    var background: AnyShapeStyle = AnyShapeStyle(Brand.cardFill)
    let content: () -> Content

    init(padding: CGFloat = Brand.Space.l,
         background: AnyShapeStyle = AnyShapeStyle(Brand.cardFill),
         @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.background = background
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Brand.Radius.l, style: .continuous)
                    .fill(background)
            )
            .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Section header

struct BrandSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var accessory: AnyView? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(Brand.Font.title2)
                if let s = subtitle {
                    Text(s).font(Brand.Font.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            accessory
        }
        .padding(.horizontal, Brand.Space.s)
    }
}

// MARK: - Primary / secondary buttons

struct PrimaryButtonStyle: ButtonStyle {
    var prominent: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Brand.Font.bodyEmphasis)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: Brand.Radius.l, style: .continuous)
                    .fill(prominent ? AnyShapeStyle(Brand.heroGradient) : AnyShapeStyle(Brand.primary))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
            .shadow(color: Brand.primary.opacity(0.25), radius: 14, x: 0, y: 8)
    }
}

struct GoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Brand.Font.bodyEmphasis)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: Brand.Radius.l, style: .continuous)
                    .fill(Brand.goldGradient)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .shadow(color: Brand.warning.opacity(0.35), radius: 14, x: 0, y: 8)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Brand.Font.bodyEmphasis)
            .foregroundStyle(Brand.primary)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                RoundedRectangle(cornerRadius: Brand.Radius.l, style: .continuous)
                    .fill(Brand.primary.opacity(0.1))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}

// MARK: - Stat chip / KPI

struct StatChip: View {
    let icon: String
    let title: String
    let value: String
    var tint: Color = Brand.primary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 13, weight: .bold))
                Text(title).font(Brand.Font.captionEmphasis)
            }
            .foregroundStyle(tint)
            Text(value).font(Brand.Font.monoNumber).foregroundStyle(Brand.ink)
        }
        .padding(Brand.Space.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Brand.Radius.m, style: .continuous)
                .fill(tint.opacity(0.08))
        )
    }
}

// MARK: - Pro lock badge

struct ProBadge: View {
    var label: String = "PRO"
    var body: some View {
        Text(label)
            .font(.system(size: 10, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(Capsule().fill(Brand.goldGradient))
    }
}

struct ProLockOverlay: ViewModifier {
    let isLocked: Bool
    let onTap: () -> Void
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                if isLocked { ProBadge().padding(8) }
            }
            .overlay {
                if isLocked {
                    RoundedRectangle(cornerRadius: Brand.Radius.l, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "lock.fill").font(.title2)
                                Text("Pro 解鎖").font(Brand.Font.bodyEmphasis)
                            }
                            .foregroundStyle(Brand.primary)
                        }
                        .onTapGesture(perform: onTap)
                }
            }
    }
}

extension View {
    func proLock(_ locked: Bool, onTap: @escaping () -> Void) -> some View {
        modifier(ProLockOverlay(isLocked: locked, onTap: onTap))
    }
}

// MARK: - Empty state

struct EmptyStateView: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    /// 自訂插圖（資產目錄名稱）；若有則優先顯示，沒有則 fall back 到 SF Symbol。
    var assetName: String? = nil

    var body: some View {
        VStack(spacing: Brand.Space.m) {
            ZStack {
                Circle().fill(Brand.primary.opacity(0.08))
                if let name = assetName {
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .padding(18)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(Brand.primary.opacity(0.6))
                }
            }
            .frame(width: 180, height: 180)

            Text(title).font(Brand.Font.title2)
            if let s = subtitle {
                Text(s).font(Brand.Font.caption).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            if let actionTitle, let action {
                Button(actionTitle, action: action).buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, Brand.Space.xxl)
            }
        }
        .padding(Brand.Space.xxl)
    }
}

// MARK: - Progress ring

struct ProgressRing: View {
    var progress: Double           // 0…1
    var label: String
    var value: String
    var lineWidth: CGFloat = 12
    var diameter: CGFloat = 130

    var body: some View {
        ZStack {
            Circle()
                .stroke(Brand.primary.opacity(0.1), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, min(progress, 1)))
                .stroke(Brand.heroGradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            VStack(spacing: 2) {
                Text(value).font(.system(size: 28, weight: .bold, design: .rounded)).foregroundStyle(Brand.ink)
                Text(label).font(Brand.Font.caption).foregroundStyle(.secondary)
            }
        }
        .frame(width: diameter, height: diameter)
    }
}

// MARK: - Soft divider

struct BrandDivider: View {
    var body: some View {
        Rectangle().fill(Color.primary.opacity(0.08)).frame(height: 1)
    }
}
