import SwiftUI

struct SettingsView: View {
    @Environment(WikiSettings.self) private var settings
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Form {
            HStack(spacing: AD.S.sm) {
                TextField("Wiki Path", text: Bindable(settings).wikiPath)
                    .font(AD.body)
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
                .font(AD.caption)
                .foregroundStyle(AD.inkMuted48(scheme))
        }
        .padding(AD.S.lg)
        .frame(width: 440)
    }
}
