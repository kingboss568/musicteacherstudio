import XCTest
@testable import MusicTeacherStudio

final class AssignmentServiceTests: XCTestCase {
    let svc = AssignmentService()
    let studentID = UUID()

    func testCreateAssignmentDefaultsToOpen() {
        let a = svc.createAssignment(studentID: studentID, title: "練 Hanon",
                                     instruction: "10 min/day")
        XCTAssertEqual(a.status, .open)
        XCTAssertEqual(a.studentID, studentID)
    }

    func testUpdateStatus() {
        let a = svc.createAssignment(studentID: studentID, title: "x", instruction: "y")
        svc.updateStatus(a, status: .completed)
        XCTAssertEqual(a.status, .completed)
    }

    func testOpenAssignmentsFilter() {
        let a1 = svc.createAssignment(studentID: studentID, title: "1", instruction: "")
        let a2 = svc.createAssignment(studentID: studentID, title: "2", instruction: "")
        svc.updateStatus(a2, status: .completed)
        let other = svc.createAssignment(studentID: UUID(), title: "x", instruction: "")
        let result = svc.openAssignments(for: studentID, assignments: [a1, a2, other])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, a1.id)
    }

    func testLinkAssignment() {
        let a = svc.createAssignment(studentID: studentID, title: "t", instruction: "i")
        let lid = UUID()
        svc.linkAssignment(a, to: lid)
        XCTAssertEqual(a.lessonID, lid)
    }
}
