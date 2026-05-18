import SwiftUI

/// 音律手帳 — Brand design tokens.
///
/// 品牌色定位：
/// - Primary（深靛紫 #4F46E5 → #6D28D9）：專業、信任、音樂感
/// - Accent（暖金 #F59E0B）：時間、價值、Pro 解鎖
/// - Surface（米白 #FAFAF7）：溫暖、紙感、不刺眼
/// - Ink（深炭 #18181B）：文字主色
/// - Success（#10B981）/ Warning（#F59E0B）/ Danger（#EF4444）
enum Brand {

    // MARK: - Colors (resolved from Asset Catalog where available, else literal)

    static let primary    = Color("BrandPrimary",  bundle: nil)
    static let primaryDeep = Color(red: 0.31, green: 0.16, blue: 0.85)   // #4F28DA
    static let accent     = Color("BrandAccent",   bundle: nil)
    static let surface    = Color("BrandSurface",  bundle: nil)
    static let ink        = Color("BrandInk",      bundle: nil)
    static let gold       = Color("BrandGold",     bundle: nil)

    static let success    = Color(red: 0.06, green: 0.73, blue: 0.51)    // #10B981
    static let warning    = Color(red: 0.96, green: 0.62, blue: 0.04)    // #F59E0B
    static let danger     = Color(red: 0.94, green: 0.27, blue: 0.27)    // #EF4444

    /// Subtle background for cards in light mode.
    static let cardFill   = Color(.secondarySystemGroupedBackground)

    // MARK: - Gradients

    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.31, green: 0.18, blue: 0.85),
            Color(red: 0.55, green: 0.32, blue: 0.95)
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let goldGradient = LinearGradient(
        colors: [
            Color(red: 0.99, green: 0.78, blue: 0.27),
            Color(red: 0.94, green: 0.55, blue: 0.05)
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let glassGradient = LinearGradient(
        colors: [Color.white.opacity(0.85), Color.white.opacity(0.55)],
        startPoint: .top, endPoint: .bottom
    )

    // MARK: - Spacing

    enum Space {
        static let xs: CGFloat  = 4
        static let s:  CGFloat  = 8
        static let m:  CGFloat  = 12
        static let l:  CGFloat  = 16
        static let xl: CGFloat  = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }

    // MARK: - Corner radius

    enum Radius {
        static let s:  CGFloat = 8
        static let m:  CGFloat = 12
        static let l:  CGFloat = 16
        static let xl: CGFloat = 22
        static let pill: CGFloat = 999
    }

    // MARK: - Shadow

    enum Shadow {
        static func soft(_ color: Color = .black.opacity(0.06)) -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            (color, 14, 0, 6)
        }
        static func sharp(_ color: Color = .black.opacity(0.10)) -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            (color, 4, 0, 2)
        }
    }

    // MARK: - Typography

    enum Font {
        static let display = SwiftUI.Font.system(size: 34, weight: .bold,    design: .rounded)
        static let title   = SwiftUI.Font.system(size: 22, weight: .semibold, design: .rounded)
        static let title2  = SwiftUI.Font.system(size: 18, weight: .semibold, design: .rounded)
        static let body    = SwiftUI.Font.system(size: 16, weight: .regular,  design: .default)
        static let bodyEmphasis = SwiftUI.Font.system(size: 16, weight: .semibold, design: .default)
        static let caption = SwiftUI.Font.system(size: 13, weight: .regular,  design: .default)
        static let captionEmphasis = SwiftUI.Font.system(size: 13, weight: .semibold, design: .default)
        static let monoNumber = SwiftUI.Font.system(.title2, design: .rounded).monospacedDigit().weight(.bold)
    }

    // MARK: - Strings (i18n later via Localizable)

    enum Strings {
        static let productName        = "音律手帳"
        static let productNameEnglish = "MusicTeacher Studio"
        static let tagline            = "30 秒記錄，30 年成長"
        static let proName            = "音律手帳 Pro"
    }
}
