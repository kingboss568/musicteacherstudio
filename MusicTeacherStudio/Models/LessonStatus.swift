import Foundation

enum LessonStatus: String, Codable, CaseIterable, Identifiable {
    case scheduled
    case attended
    case cancelled
    case noShow

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .scheduled: return "已排課"
        case .attended:  return "已出席"
        case .cancelled: return "已取消"
        case .noShow:    return "缺席"
        }
    }
}
