import Foundation

struct AssignmentService {
    func createAssignment(
        studentID: UUID,
        lessonID: UUID? = nil,
        title: String,
        instruction: String,
        dueDate: Date? = nil
    ) -> Assignment {
        Assignment(
            studentID: studentID,
            lessonID: lessonID,
            title: title,
            instruction: instruction,
            dueDate: dueDate,
            status: .open
        )
    }

    func updateStatus(_ assignment: Assignment, status: AssignmentStatus) {
        assignment.status = status
        assignment.updatedAt = .now
    }

    func openAssignments(for studentID: UUID, assignments: [Assignment]) -> [Assignment] {
        assignments.filter { $0.studentID == studentID && $0.status == .open }
    }

    func linkAssignment(_ assignment: Assignment, to lessonID: UUID?) {
        assignment.lessonID = lessonID
        assignment.updatedAt = .now
    }
}
