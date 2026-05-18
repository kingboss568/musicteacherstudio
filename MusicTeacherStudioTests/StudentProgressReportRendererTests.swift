import XCTest
@testable import MusicTeacherStudio

final class StudentProgressReportRendererTests: XCTestCase {
    func testRenderProducesValidPDFFile() throws {
        let renderer = StudentProgressReportRenderer()
        let student = Student(name: "測試學生", instrument: "鋼琴", level: "初級",
                              defaultLessonFeeCents: 800)
        let lesson = Lesson(studentID: student.id, scheduledStart: .now,
                            scheduledEnd: .now.addingTimeInterval(3600),
                            status: .attended, feeCents: 800,
                            teacherNote: "節奏穩定。")
        let url = try renderer.renderProgressReport(
            student: student, lessons: [lesson], assignments: [], recordings: []
        )
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertEqual(url.pathExtension.lowercased(), "pdf")
        addTeardownBlock { try? FileManager.default.removeItem(at: url) }
    }
}
