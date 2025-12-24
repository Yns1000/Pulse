import SwiftUI
import SwiftData

@main
struct PulseApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
