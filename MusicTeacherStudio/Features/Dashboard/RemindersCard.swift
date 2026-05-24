import SwiftUI

struct RemindersCard: View {
    let reminders: [SmartRemindersService.Reminder]

    var body: some View {
        BrandCard {
            VStack(alignment: .leading, spacing: Brand.Space.s) {
                BrandSectionHeader(
                    title: "今日提醒",
                    subtitle: reminders.isEmpty ? "全部都在掌握中 ✨" : "\(reminders.count) 則"
                )
                if reminders.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(Brand.success)
                        Text("沒有需要立刻處理的事")
                            .font(Brand.Font.caption).foregroundStyle(.secondary)
                    }
                } else {
                    ForEach(reminders) { r in
                        ReminderRow(reminder: r)
                    }
                }
            }
        }
    }
}

private struct ReminderRow: View {
    let reminder: SmartRemindersService.Reminder

    var tint: Color {
        switch reminder.severity {
        case .info:    return Brand.primary
        case .warning: return Brand.warning
        case .alert:   return Brand.danger
        }
    }

    var body: some View {
        HStack(spacing: Brand.Space.m) {
            Image(systemName: reminder.symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(RoundedRectangle(cornerRadius: 9).fill(tint))
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title).font(Brand.Font.bodyEmphasis).foregroundStyle(Brand.ink)
                Text(reminder.detail).font(Brand.Font.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if let actionLabel = reminder.actionLabel {
                Text(actionLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(tint.opacity(0.15)))
                    .foregroundStyle(tint)
            }
        }
        .padding(.vertical, 4)
    }
}
