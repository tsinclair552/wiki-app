import SwiftUI

@main
struct WikiApp: App {
    @State private var settings = WikiSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
                .frame(minWidth: 720, minHeight: 400)
        }
        .windowResizability(.contentMinSize)
        .commands {
            SidebarCommands()
            CommandGroup(replacing: .help) {
                Link("Wiki Reader Help", destination: URL(string: "https://github.com/tsinclair/wiki-app")!)
            }
        }

        Settings {
            SettingsView()
                .environment(settings)
        }
    }
}
