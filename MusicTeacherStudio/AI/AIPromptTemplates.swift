import Foundation

struct ParentMessageInput {
    var studentName: String
    var instrument: String
    var level: String?
    var lessonNote: String
    var assignments: [Assignment]
    var toneHint: String?
}

struct ParentMessageDraft {
    var shortVersion: String
    var standardVersion: String
    var encouragingVersion: String
}

struct LessonSummaryInput {
    var student: Student
    var recentLessons: [Lesson]
    var recentAssignments: [Assignment]
}

struct LessonSummaryOutput {
    var focusAreas: String
    var observedProgress: String
    var needsStabilization: String
    var nextPracticePlan: String
    var parentSummary: String
}

enum AIPromptTemplates {
    static let safetyClauses = """
    重要約束：
    - 請使用繁體中文。
    - 語氣需溫和、具體、鼓勵，並提供可行動的建議。
    - 不評斷學生天分。
    - 不對學生做能力評分、排名或定級。
    - 不使用「差」、「沒天分」、「不適合」等負面標籤。
    - 不加入老師未提供的事實。
    - 不要提及「AI」。
    - 所有輸出皆為老師可編輯草稿，不可直接發送。
    """

    static func parentMessage(input: ParentMessageInput) -> String {
        let assignmentLines = input.assignments
            .map { "- \($0.title)：\($0.instruction)" }
            .joined(separator: "\n")
        return """
        [KIND:parentMessage]
        請根據以下老師課堂筆記，產出 3 個版本的家長訊息草稿：簡短版、標準版、鼓勵版。
        每個版本 120–200 字，繁體中文，結尾給一個家中可執行的小練習建議。

        studentName: \(input.studentName)
        instrument: \(input.instrument)
        level: \(input.level ?? "")
        lessonNote: \(input.lessonNote)
        toneHint: \(input.toneHint ?? "")
        assignments:
        \(assignmentLines)

        \(safetyClauses)
        """
    }

    static func progressSummary(input: LessonSummaryInput) -> String {
        let lessonLines = input.recentLessons.prefix(4).map { l in
            "- \(l.scheduledStart) \(l.status.displayName)：\(l.teacherNote ?? "")"
        }.joined(separator: "\n")
        let assignmentLines = input.recentAssignments.map { a in
            "- \(a.title)（\(a.status.displayName)）"
        }.joined(separator: "\n")
        return """
        [KIND:progressSummary]
        請根據最近 4 堂課的紀錄產出學習進度摘要。輸出需包含五個段落：
        最近練習重點、已觀察到的進展、仍需穩定的地方、下週建議練習、給家長的簡短版本。
        只描述觀察到的練習內容與進展，不做能力定級。

        studentName: \(input.student.name)
        instrument: \(input.student.instrument)
        level: \(input.student.level ?? "")
        recentLessons:
        \(lessonLines)
        recentAssignments:
        \(assignmentLines)

        \(safetyClauses)
        """
    }

    static func nextPracticePlan(student: Student, recentLessons: [Lesson], assignments: [Assignment]) -> String {
        return """
        [KIND:nextPracticePlan]
        請為以下學生產出 3–5 個下週練習項目。每個項目包含建議練習時間，語氣為老師可修改的草稿。
        不要使用能力評分或排名語句。

        studentName: \(student.name)
        instrument: \(student.instrument)
        level: \(student.level ?? "")

        \(safetyClauses)
        """
    }
}
