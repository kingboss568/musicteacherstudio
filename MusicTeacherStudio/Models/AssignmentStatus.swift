import Foundation

enum AssignmentStatus: String, Codable, CaseIterable, Identifiable {
    case open
    case completed
    case reviewed
    case archived

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .open:      return "進行中"
        case .completed: return "已完成"
        case .reviewed:  return "已檢查"
        case .archived:  return "已封存"
        }
    }
}
