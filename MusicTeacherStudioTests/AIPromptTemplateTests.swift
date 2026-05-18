import XCTest
@testable import MusicTeacherStudio

final class AIPromptTemplateTests: XCTestCase {

    private func sampleInput() -> ParentMessageInput {
        ParentMessageInput(
            studentName: "陳家樂",
            instrument: "鋼琴",
            level: "中級",
            lessonNote: "節奏穩定。",
            assignments: [],
            toneHint: nil
        )
    }

    func testParentMessagePromptContainsTraditionalChineseClause() {
        let p = AIPromptTemplates.parentMessage(input: sampleInput())
        XCTAssertTrue(p.contains("繁體中文"))
    }

    func testParentMessagePromptForbidsTalentJudgment() {
        let p = AIPromptTemplates.parentMessage(input: sampleInput())
        XCTAssertTrue(p.contains("不評斷學生天分"))
        XCTAssertTrue(p.contains("不對學生做能力評分") || p.contains("不做能力定級") || p.contains("能力評分"))
    }

    func testParentMessagePromptRequiresEditableDraft() {
        let p = AIPromptTemplates.parentMessage(input: sampleInput())
        XCTAssertTrue(p.contains("草稿"))
        XCTAssertTrue(p.contains("不可直接發送"))
    }

    func testParentMessagePromptHasNoAutomatedSendingInstruction() {
        let p = AIPromptTemplates.parentMessage(input: sampleInput())
        XCTAssertFalse(p.contains("自動發送"))
        XCTAssertFalse(p.contains("直接傳送"))
    }

    func testProgressSummaryPromptContainsRequiredSections() {
        let student = Student(name: "x", instrument: "鋼琴", defaultLessonFeeCents: 0)
        let p = AIPromptTemplates.progressSummary(input: LessonSummaryInput(
            student: student, recentLessons: [], recentAssignments: []
        ))
        XCTAssertTrue(p.contains("最近練習重點"))
        XCTAssertTrue(p.contains("已觀察到的進展"))
        XCTAssertTrue(p.contains("仍需穩定的地方"))
        XCTAssertTrue(p.contains("下週建議練習"))
        XCTAssertTrue(p.contains("給家長的簡短版本"))
    }

    func testNextPracticePlanPromptForbidsAbilityScores() {
        let student = Student(name: "x", instrument: "鋼琴", defaultLessonFeeCents: 0)
        let p = AIPromptTemplates.nextPracticePlan(student: student, recentLessons: [], assignments: [])
        XCTAssertTrue(p.contains("不要使用能力評分"))
    }

    // Behavior of the mock provider end-to-end

    func testMockProviderProducesThreeVersionedParentMessage() async throws {
        let drafter = ParentMessageDraftAI(provider: MockAIProvider())
        let draft = try await drafter.draftParentMessage(input: sampleInput())
        XCTAssertFalse(draft.shortVersion.isEmpty)
        XCTAssertFalse(draft.standardVersion.isEmpty)
        XCTAssertFalse(draft.encouragingVersion.isEmpty)
        // No banned negative-label phrases anywhere in the output.
        let combined = draft.shortVersion + draft.standardVersion + draft.encouragingVersion
        for banned in ["沒天分", "不適合", "差勁"] {
            XCTAssertFalse(combined.contains(banned), "Draft should not contain '\(banned)'")
        }
    }

    func testMockProviderProducesParsedSummary() async throws {
        let student = Student(name: "x", instrument: "鋼琴", defaultLessonFeeCents: 0)
        let summarizer = LessonSummaryAI(provider: MockAIProvider())
        let output = try await summarizer.summarize(input: LessonSummaryInput(
            student: student, recentLessons: [], recentAssignments: []
        ))
        XCTAssertFalse(output.focusAreas.isEmpty)
        XCTAssertFalse(output.parentSummary.isEmpty)
        XCTAssertFalse(output.nextPracticePlan.isEmpty)
    }
}
