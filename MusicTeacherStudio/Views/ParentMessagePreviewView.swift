import SwiftUI
import UIKit

struct ParentMessagePreviewView: View {
    let input: ParentMessageInput
    private let drafter: ParentMessageDrafting = ParentMessageDraftAI(provider: MockAIProvider())

    @State private var draft: ParentMessageDraft?
    @State private var selected: Version = .standard
    @State private var editingText: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    enum Version: String, CaseIterable, Identifiable {
        case short, standard, encouraging
        var id: String { rawValue }
        var label: String {
            switch self {
            case .short: return "簡短"
            case .standard: return "標準"
            case .encouraging: return "鼓勵"
            }
        }
    }

    var body: some View {
        Form {
            Section {
                Text("此內容為草稿，請老師確認後再傳送。")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }
            Section("版本") {
                Picker("版本", selection: $selected) {
                    ForEach(Version.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
                .onChange(of: selected) { _, _ in syncSelectedText() }
            }
            Section("草稿（可編輯）") {
                if isLoading {
                    ProgressView("產生中…")
                } else {
                    TextEditor(text: $editingText)
                        .frame(minHeight: 200)
                }
            }
            Section {
                Button {
                    UIPasteboard.general.string = editingText
                } label: {
                    Label("複製草稿", systemImage: "doc.on.doc")
                }
                .disabled(editingText.isEmpty)

                Button {
                    Task { await generate() }
                } label: {
                    Label("重新產生", systemImage: "arrow.clockwise")
                }
                .disabled(isLoading)
            }
        }
        .navigationTitle("家長訊息草稿")
        .task { await generate() }
        .alert("產生失敗", isPresented: .constant(errorMessage != nil)) {
            Button("好", role: .cancel) { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    private func generate() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let d = try await drafter.draftParentMessage(input: input)
            draft = d
            syncSelectedText()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func syncSelectedText() {
        guard let d = draft else { return }
        switch selected {
        case .short:       editingText = d.shortVersion
        case .standard:    editingText = d.standardVersion
        case .encouraging: editingText = d.encouragingVersion
        }
    }
}

#Preview {
    NavigationStack {
        ParentMessagePreviewView(input: ParentMessageInput(
            studentName: "陳家樂",
            instrument: "鋼琴",
            level: "中級",
            lessonNote: "節奏穩定度有進步。",
            assignments: [],
            toneHint: nil
        ))
    }
}
