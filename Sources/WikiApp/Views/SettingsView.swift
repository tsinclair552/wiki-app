import SwiftUI

struct SettingsView: View {
    @Environment(WikiSettings.self) private var settings

    var body: some View {
        Form {
            HStack {
                TextField("Wiki Path", text: Bindable(settings).wikiPath)
                    .font(.body)
                Button("Browse…") {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.canCreateDirectories = false
                    panel.begin { response in
                        if response == .OK, let url = panel.url {
                            settings.wikiPath = url.path
                        }
                    }
                }
            }

            Text("Path to your wiki hub (default: ~/wiki)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 400)
    }
}
