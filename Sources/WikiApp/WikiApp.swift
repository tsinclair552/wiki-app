import SwiftUI

@main
struct WikiApp: App {
    @State private var settings = WikiSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
                .frame(minWidth: 900, minHeight: 500)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentMinSize)

        Settings {
            SettingsView()
                .environment(settings)
        }
    }
}
