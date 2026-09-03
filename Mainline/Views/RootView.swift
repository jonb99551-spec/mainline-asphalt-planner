import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack { CalculatorView() }
                .tabItem { Label("Daily Plan", systemImage: "road.lanes") }

            NavigationStack { SavedJobsView() }
                .tabItem { Label("Saved Plans", systemImage: "folder") }
        }
        .tint(.orange)
    }
}
