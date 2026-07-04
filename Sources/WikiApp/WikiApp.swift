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

@Observable
final class WikiSettings {
    var wikiPath: String {
        didSet { UserDefaults.standard.set(wikiPath, forKey: "wikiPath") }
    }

    init() {
        self.wikiPath = UserDefaults.standard.string(forKey: "wikiPath")
            ?? FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("wiki").path
    }
}
