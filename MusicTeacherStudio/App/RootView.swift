import SwiftUI

struct RootView: View {
    @State private var selectedTab: AppTab
    @State private var showLaunchPaywall: Bool

    init(route: ScreenshotLaunchRoute = ScreenshotLaunchRoute()) {
        _selectedTab = State(initialValue: route.tab)
        _showLaunchPaywall = State(initialValue: route.showsPaywall)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { DashboardView() }
                .tabItem { Label("首頁", systemImage: "house.fill") }
                .tag(AppTab.dashboard)
            NavigationStack { StudentListView() }
                .tabItem { Label("學生", systemImage: "person.2.fill") }
                .tag(AppTab.students)
            NavigationStack { LessonCalendarView() }
                .tabItem { Label("課表", systemImage: "calendar") }
                .tag(AppTab.lessons)
            NavigationStack { PaymentTrackerView() }
                .tabItem { Label("收費", systemImage: "creditcard.fill") }
                .tag(AppTab.payments)
            NavigationStack { SettingsView() }
                .tabItem { Label("設定", systemImage: "gearshape.fill") }
                .tag(AppTab.settings)
        }
        .sheet(isPresented: $showLaunchPaywall) {
            PaywallView()
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewData.makeContainer())
        .environmentObject(StoreKitManager.shared)
}
