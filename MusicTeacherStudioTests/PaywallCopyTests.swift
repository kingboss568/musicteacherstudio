import XCTest
@testable import MusicTeacherStudio

final class PaywallCopyTests: XCTestCase {
    func testFAQDoesNotPromiseUnimplementedCloudSync() {
        let combined = PaywallFAQ.all
            .map { "\($0.question) \($0.answer)" }
            .joined(separator: " ")

        XCTAssertFalse(combined.localizedCaseInsensitiveContains("iCloud"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("雲端"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("自動跨裝置"))
    }
}
