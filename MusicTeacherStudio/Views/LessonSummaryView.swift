import SwiftUI
import UIKit

struct LessonSummaryView: View {
    let input: LessonSummaryInput
    private let summarizer: LessonSummarizing = LessonSummaryAI(provider: MockAIProvider())

    @State private var output: LessonSummaryOutput?
    @State private var nextPlan: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section {
                Text("此內容為草稿，請老師確認後再使用。")
                    .font(.footnote).foregroundStyle(.orange)
            }
            if isLoading {
                Section { ProgressView("產生中…") }
            } else if let o = output {
                section("最近練習重點", o.focusAreas)
                section("已觀察到的進展", o.observedProgress)
                section("仍需穩定的地方", o.needsStabilization)
                section("下週建議練習", o.nextPracticePlan)
                section("給家長的簡短版本", o.parentSummary)
            }

            Section("下週練習清單草稿") {
                if nextPlan.isEmpty {
                    Text("尚未產生").foregroundStyle(.secondary)
                } else {
                    Text(nextPlan)
                }
                Button {
                    UIPasteboard.general.string = nextPlan
                } label: { Label("複製練習清單", systemImage: "doc.on.doc") }
                .disabled(nextPlan.isEmpty)
            }

            Section {
                Button {
                    Task { await generate() }
                } label: { Label("重新產生", systemImage: "arrow.clockwise") }
                .disabled(isLoading)
            }
        }
        .navigationTitle("AI 學習摘要")
        .task { await generate() }
        .alert("產生失敗", isPresented: .constant(errorMessage != nil)) {
            Button("好", role: .cancel) { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    @ViewBuilder
    private func section(_ title: String, _ body: String) -> some View {
        if !body.isEmpty {
            Section(title) {
                Text(body)
                Button {
                    UIPasteboard.general.string = body
                } label: { Label("複製此段", systemImage: "doc.on.doc") }
            }
        }
    }

    private func generate() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let summary = summarizer.summarize(input: input)
            async let plan = summarizer.nextPracticePlan(
                for: input.student,
                recentLessons: input.recentLessons,
                assignments: input.recentAssignments
            )
            output = try await summary
            nextPlan = try await plan
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
