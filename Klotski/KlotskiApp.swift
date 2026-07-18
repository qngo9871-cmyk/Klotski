import SwiftUI

@main
struct KlotskiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LocalizationManager.shared)
        }
    }
}
