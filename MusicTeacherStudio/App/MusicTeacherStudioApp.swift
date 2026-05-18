import SwiftUI
import SwiftData

@main
struct MusicTeacherStudioApp: App {
    @StateObject private var store = StoreKitManager.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    private let modelContainer: ModelContainer = Self.makeModelContainer()

#if DEBUG
    private var isScreenshotMode: Bool {
        ProcessInfo.processInfo.arguments.contains("-MTSUsePreviewData")
    }
#else
    private var isScreenshotMode: Bool { false }
#endif

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding || isScreenshotMode {
                    RootView()
                        .environmentObject(store)
                        .task { await store.bootstrap() }
                } else {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                        .environmentObject(store)
                }
            }
            .tint(Brand.primary)
        }
        .modelContainer(modelContainer)
    }

    @MainActor
    private static func makeModelContainer() -> ModelContainer {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-MTSUsePreviewData") {
            return PreviewData.makeContainer()
        }
#endif
        return try! ModelContainer(for: PreviewData.schema)
    }
}
