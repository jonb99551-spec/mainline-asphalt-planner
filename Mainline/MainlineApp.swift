import SwiftUI

@main
struct MainlineApp: App {
    @StateObject private var jobStore = JobStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(jobStore)
        }
    }
}
