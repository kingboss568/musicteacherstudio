import SwiftUI

/// 視覺化的連續紀錄卡片。Pro 顯示完整歷史 + 火焰特效，免費只顯示今日狀態。
struct StreakCard: View {
    let result: StreakService.StreakResult
    let isPro: Bool
    var onTapUpgrade: () -> Void

    private var flameSize: CGFloat {
        switch result.currentStreak {
        case 0:        return 36
        case 1...6:    return 42
        case 7...20:   return 54
        case 21...60:  return 66
        default:       return 78
        }
    }

    private var flameColors: [Color] {
        switch result.currentStreak {
        case 0:       return [.gray.opacity(0.45), .gray.opacity(0.25)]
        case 1...6:   return [Color(red: 1.0, green: 0.65, blue: 0.32), Color(red: 1.0, green: 0.83, blue: 0.45)]
        case 7...20:  return [Color(red: 1.0, green: 0.45, blue: 0.18), Color(red: 1.0, green: 0.78, blue: 0.27)]
        case 21...60: return [Color(red: 0.95, green: 0.20, blue: 0.30), Color(red: 1.0, green: 0.65, blue: 0.12)]
        default:      return [Color(red: 0.55, green: 0.10, blue: 0.95), Color(red: 1.0, green: 0.45, blue: 0.18)]
        }
    }

    private var motto: String {
        switch result.currentStreak {
        case 0: return "今天打開 App，紀錄第一堂課就開始連勝。"
        case 1...3: return "好的開始！再堅持一點養成習慣。"
        case 4...6: return "進入軌道，下一個里程碑是 7 天！"
        case 7...20: return "穩定產出 — 你正在成為值得信賴的老師。"
        case 21...60: return "驚人！學生家長一定感受得到。"
        default: return "傳奇等級。請務必保持。"
        }
    }

    var body: some View {
        BrandCard {
            VStack(alignment: .leading, spacing: Brand.Space.m) {
                HStack {
                    BrandSectionHeader(
                        title: "連續紀錄",
                        subtitle: result.lastActiveDay.map { "上次：\(DateFormatterUtility.dateString($0))" } ?? "尚未開始"
                    )
                    Spacer()
                    if !isPro { ProBadge(label: "Pro 看歷史") }
                }
                HStack(alignment: .center, spacing: Brand.Space.l) {
                    // Flame
                    ZStack {
                        ForEach(0..<3) { i in
                            Image(systemName: "flame.fill")
                                .font(.system(size: flameSize - CGFloat(i * 6), weight: .black))
                                .foregroundStyle(
                                    LinearGradient(colors: flameColors,
                                                   startPoint: .top, endPoint: .bottom)
                                )
                                .opacity(1 - Double(i) * 0.18)
                                .scaleEffect(1 - CGFloat(i) * 0.06)
                                .blur(radius: CGFloat(i) * 0.6)
                        }
                    }
                    .frame(width: 90, height: 90)
                    .background(
                        Circle().fill(flameColors.first?.opacity(0.10) ?? .clear)
                    )
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(result.currentStreak)")
                                .font(.system(size: 44, weight: .heavy, design: .rounded))
                                .foregroundStyle(Brand.ink)
                                .contentTransition(.numericText())
                            Text("天").font(Brand.Font.title2).foregroundStyle(.secondary)
                        }
                        Text(motto)
                            .font(Brand.Font.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
                if isPro {
                    HStack(spacing: Brand.Space.m) {
                        statBox("最長", "\(result.longestStreak) 天")
                        statBox("總活躍", "\(result.totalActiveDays) 天")
                    }
                } else {
                    Button {
                        Haptics.select()
                        onTapUpgrade()
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                            Text("解鎖完整歷史與最長紀錄")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(Brand.Font.captionEmphasis)
                        .padding(Brand.Space.m)
                        .background(
                            RoundedRectangle(cornerRadius: Brand.Radius.m)
                                .fill(Brand.goldGradient)
                        )
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func statBox(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(Brand.Font.caption).foregroundStyle(.secondary)
            Text(value).font(Brand.Font.bodyEmphasis).foregroundStyle(Brand.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Brand.Space.m)
        .background(RoundedRectangle(cornerRadius: Brand.Radius.m).fill(Color(.tertiarySystemFill)))
    }
}
