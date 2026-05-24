import SwiftUI

/// 圓形彩色字首頭像 — 根據姓名 hash 自動配色，每位學生都有個性。
struct StudentAvatar: View {
    let name: String
    let instrument: String
    var size: CGFloat = 44

    private static let palette: [(Color, Color)] = [
        (Color(red: 0.31, green: 0.18, blue: 0.85), Color(red: 0.49, green: 0.38, blue: 0.98)),
        (Color(red: 0.96, green: 0.62, blue: 0.04), Color(red: 0.99, green: 0.78, blue: 0.27)),
        (Color(red: 0.06, green: 0.73, blue: 0.51), Color(red: 0.20, green: 0.85, blue: 0.66)),
        (Color(red: 0.94, green: 0.27, blue: 0.27), Color(red: 0.99, green: 0.45, blue: 0.45)),
        (Color(red: 0.30, green: 0.50, blue: 0.96), Color(red: 0.48, green: 0.69, blue: 1.00)),
        (Color(red: 0.86, green: 0.40, blue: 0.84), Color(red: 0.99, green: 0.60, blue: 0.95)),
        (Color(red: 0.16, green: 0.62, blue: 0.83), Color(red: 0.35, green: 0.80, blue: 0.94))
    ]

    private var colors: (Color, Color) {
        let h = abs(name.hashValue) % Self.palette.count
        return Self.palette[h]
    }

    private var initial: String {
        if let first = name.unicodeScalars.first {
            return String(first)
        }
        return "?"
    }

    private var instrumentSymbol: String {
        let s = instrument
        if s.contains("鋼琴") || s.lowercased().contains("piano") { return "pianokeys" }
        if s.contains("小提") || s.lowercased().contains("violin") { return "music.quarternote.3" }
        if s.contains("吉他") || s.lowercased().contains("guitar") { return "guitars" }
        if s.contains("聲樂") || s.lowercased().contains("vocal") || s.contains("唱")  { return "mic" }
        if s.contains("鼓")  || s.lowercased().contains("drum") { return "circle.dotted" }
        if s.contains("長笛") || s.contains("笛") || s.lowercased().contains("flute") { return "wind" }
        return "music.note"
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [colors.0, colors.1],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            Text(initial)
                .font(.system(size: size * 0.46, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .overlay(alignment: .bottomTrailing) {
            ZStack {
                Circle().fill(.white).frame(width: size * 0.36, height: size * 0.36)
                Image(systemName: instrumentSymbol)
                    .font(.system(size: size * 0.18, weight: .bold))
                    .foregroundStyle(colors.0)
            }
            .offset(x: 2, y: 2)
        }
        .shadow(color: colors.0.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    HStack(spacing: 12) {
        StudentAvatar(name: "陳家樂", instrument: "鋼琴")
        StudentAvatar(name: "林小妮", instrument: "小提琴", size: 56)
        StudentAvatar(name: "黃志明", instrument: "吉他", size: 72)
        StudentAvatar(name: "Olivia", instrument: "vocal", size: 44)
    }
    .padding()
}
