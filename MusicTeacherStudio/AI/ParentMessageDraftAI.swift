import Foundation

protocol ParentMessageDrafting {
    func draftParentMessage(input: ParentMessageInput) async throws -> ParentMessageDraft
}

struct ParentMessageDraftAI: ParentMessageDrafting {
    let provider: AIProvider

    func draftParentMessage(input: ParentMessageInput) async throws -> ParentMessageDraft {
        let prompt = AIPromptTemplates.parentMessage(input: input)
        let raw = try await provider.complete(prompt: prompt)
        // Mock provider returns three versions separated by "---".
        let parts = raw.components(separatedBy: "\n---\n")
        if parts.count >= 3 {
            return ParentMessageDraft(
                shortVersion: parts[0].trimmingCharacters(in: .whitespacesAndNewlines),
                standardVersion: parts[1].trimmingCharacters(in: .whitespacesAndNewlines),
                encouragingVersion: parts[2].trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
        // Fallback: same content for all three versions.
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return ParentMessageDraft(
            shortVersion: trimmed,
            standardVersion: trimmed,
            encouragingVersion: trimmed
        )
    }
}
