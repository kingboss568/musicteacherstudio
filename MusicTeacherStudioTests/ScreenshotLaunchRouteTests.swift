import XCTest
@testable import MusicTeacherStudio

final class ScreenshotLaunchRouteTests: XCTestCase {
    func testDefaultsToDashboardWhenNoScreenshotArgumentExists() {
        let route = ScreenshotLaunchRoute(arguments: ["MusicTeacherStudio"])

        XCTAssertEqual(route.tab, .dashboard)
        XCTAssertFalse(route.showsPaywall)
    }

    func testParsesStudentsRoute() {
        let route = ScreenshotLaunchRoute(arguments: ["MusicTeacherStudio", "-MTSScreenshotScreen", "students"])

        XCTAssertEqual(route.tab, .students)
        XCTAssertFalse(route.showsPaywall)
    }

    func testParsesPaywallRoute() {
        let route = ScreenshotLaunchRoute(arguments: ["MusicTeacherStudio", "-MTSScreenshotScreen", "paywall"])

        XCTAssertEqual(route.tab, .settings)
        XCTAssertTrue(route.showsPaywall)
    }
}
