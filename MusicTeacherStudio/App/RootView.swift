import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack { DashboardView() }
                .tabItem { Label("首頁", systemImage: "house.fill") }
            NavigationStack { StudentListView() }
                .tabItem { Label("學生", systemImage: "person.2.fill") }
            NavigationStack { LessonCalendarView() }
                .tabItem { Label("課表", systemImage: "calendar") }
            NavigationStack { PaymentTrackerView() }
                .tabItem { Label("收費", systemImage: "creditcard.fill") }
            NavigationStack { SettingsView() }
                .tabItem { Label("設定", systemImage: "gearshape.fill") }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewData.makeContainer())
        .environmentObject(StoreKitManager.shared)
}
