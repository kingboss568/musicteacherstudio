import Foundation

/// Offline mock provider. No network. Produces template-based drafts that respect
/// all guardrails (no talent judgment, no labeling, no auto-send).
struct MockAIProvider: AIProvider {
    func complete(prompt: String) async throws -> String {
        // The prompt contains a marker tag ("[KIND:xxx]") so we can pick a sensible template.
        if prompt.contains("[KIND:parentMessage]") {
            return Self.parentMessageTemplate(from: prompt)
        }
        if prompt.contains("[KIND:progressSummary]") {
            return Self.progressSummaryTemplate(from: prompt)
        }
        if prompt.contains("[KIND:nextPracticePlan]") {
            return Self.nextPracticeTemplate(from: prompt)
        }
        return "（這是 AI 草稿範例）今天的課程已完成，老師會在下一次課堂繼續延伸練習。"
    }

    private static func extract(_ field: String, from prompt: String) -> String {
        // Looks for lines shaped like "field: value" in the prompt.
        let lines = prompt.split(separator: "\n")
        for line in lines {
            if line.hasPrefix("\(field):") {
                return String(line.dropFirst(field.count + 1)).trimmingCharacters(in: .whitespaces)
            }
        }
        return ""
    }

    private static func parentMessageTemplate(from prompt: String) -> String {
        let name = extract("studentName", from: prompt)
        let instrument = extract("instrument", from: prompt)
        let note = extract("lessonNote", from: prompt)
        let nameLabel = name.isEmpty ? "您的孩子" : "\(name)同學"
        let body = note.isEmpty ? "今天課堂上有持續練習目前的曲目。" : "今天課堂上的觀察：\(note)。"

        let short =
            "您好，\(nameLabel)今天\(instrument)課程完成。\(body)" +
            "本週建議在家保持每天 10–15 分鐘的短時間練習，先慢後快。"

        let standard =
            "您好，\(nameLabel)今天\(instrument)課程完成。\(body)" +
            "整體狀態穩定，課堂上的回應與專注度都不錯。本週建議的家中練習：" +
            "每天先用慢速確認音準與節奏，再逐步把速度提上來，10–15 分鐘即可。" +
            "如果有疑問歡迎隨時告訴我。"

        let encouraging =
            "您好，\(nameLabel)今天的\(instrument)課程表現很值得肯定。\(body)" +
            "看得出來在家有花時間練習，謝謝家長的協助。" +
            "本週可以延續這個節奏，每天安排 10–15 分鐘的短練習，重點是保持規律與輕鬆的心情。" +
            "下次課堂見！"

        return [short, "---", standard, "---", encouraging].joined(separator: "\n")
    }

    private static func progressSummaryTemplate(from prompt: String) -> String {
        let name = extract("studentName", from: prompt)
        let instrument = extract("instrument", from: prompt)
        return """
        【最近練習重點】
        \(name.isEmpty ? "學生" : name)在 \(instrument) 課程中持續延伸目前的曲目與基本功。

        【已觀察到的進展】
        近期課堂上節奏與音準的穩定度逐步提升，對於老師的提示有更快的回應。

        【仍需穩定的地方】
        部分新樂句在速度提高時容易不一致，建議從慢速練習開始穩定後再加速。

        【下週建議練習】
        - 慢速分段練習，每段重複 3 次
        - 對著節拍器以較慢速度跑完整首
        - 針對較弱段落多花 3–5 分鐘

        【給家長的簡短版本】
        最近練習狀態穩定，請繼續維持每天的短時間練習。
        """
    }

    private static func nextPracticeTemplate(from prompt: String) -> String {
        return """
        1. 基本練習（10 分鐘）：音階或 Hanon，先慢速，再逐步加速。
        2. 主曲分段練（10 分鐘）：將曲子分 2–3 段，每段重複慢練。
        3. 節拍器練習（5 分鐘）：用節拍器以較慢速度確認節奏。
        4. 自己錄一次（5 分鐘）：錄下整段練習，隔天再回放確認。
        5. 輕鬆收尾（5 分鐘）：彈一首喜歡的小段落，保持練習愉快感。
        """
    }
}
