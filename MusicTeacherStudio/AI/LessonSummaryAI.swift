import Foundation

protocol LessonSummarizing {
    func summarize(input: LessonSummaryInput) async throws -> LessonSummaryOutput
    func nextPracticePlan(for student: Student, recentLessons: [Lesson], assignments: [Assignment]) async throws -> String
}

struct LessonSummaryAI: LessonSummarizing {
    let provider: AIProvider

    func summarize(input: LessonSummaryInput) async throws -> LessonSummaryOutput {
        let prompt = AIPromptTemplates.progressSummary(input: input)
        let raw = try await provider.complete(prompt: prompt)
        return Self.parseSummary(raw)
    }

    func nextPracticePlan(for student: Student, recentLessons: [Lesson], assignments: [Assignment]) async throws -> String {
        let prompt = AIPromptTemplates.nextPracticePlan(student: student,
                                                        recentLessons: recentLessons,
                                                        assignments: assignments)
        return try await provider.complete(prompt: prompt)
    }

    private static func parseSummary(_ text: String) -> LessonSummaryOutput {
        // Extracts content for each labeled section. Sections begin with 【...】 markers.
        func extract(_ label: String) -> String {
            guard let range = text.range(of: "【\(label)】") else { return "" }
            let after = text[range.upperBound...]
            // Stop at the next 【 marker.
            if let nextMarker = after.range(of: "【") {
                return after[..<nextMarker.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return after.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return LessonSummaryOutput(
            focusAreas: extract("最近練習重點"),
            observedProgress: extract("已觀察到的進展"),
            needsStabilization: extract("仍需穩定的地方"),
            nextPracticePlan: extract("下週建議練習"),
            parentSummary: extract("給家長的簡短版本")
        )
    }
}
