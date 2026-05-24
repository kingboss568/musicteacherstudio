import Foundation

enum AppTab: Hashable {
    case dashboard
    case students
    case lessons
    case payments
    case settings
}

struct ScreenshotLaunchRoute: Equatable {
    let tab: AppTab
    let showsPaywall: Bool

    init(arguments: [String] = ProcessInfo.processInfo.arguments) {
        guard
            let flagIndex = arguments.firstIndex(of: "-MTSScreenshotScreen"),
            arguments.indices.contains(flagIndex + 1)
        else {
            self.tab = .dashboard
            self.showsPaywall = false
            return
        }

        switch arguments[flagIndex + 1].lowercased() {
        case "students":
            self.tab = .students
            self.showsPaywall = false
        case "lessons", "calendar":
            self.tab = .lessons
            self.showsPaywall = false
        case "payments", "payment":
            self.tab = .payments
            self.showsPaywall = false
        case "settings":
            self.tab = .settings
            self.showsPaywall = false
        case "paywall":
            self.tab = .settings
            self.showsPaywall = true
        default:
            self.tab = .dashboard
            self.showsPaywall = false
        }
    }
}
