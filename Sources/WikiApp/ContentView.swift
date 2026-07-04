import SwiftUI

struct ContentView: View {
    @Environment(WikiSettings.self) private var settings
    @State private var hub = WikiHub()
    @State private var selectedTopic: TopicWiki?
    @State private var selectedArticle: WikiArticle?

    var body: some View {
        NavigationSplitView {
            TopicListView(topics: hub.topics, selection: $selectedTopic)
        } content: {
            if let topic = selectedTopic {
                ArticleListView(topic: topic, selection: $selectedArticle)
            } else {
                ContentUnavailableView(
                    "Select a Topic",
                    systemImage: "book",
                    description: Text("Choose a wiki topic from the sidebar")
                )
            }
        } detail: {
            if let article = selectedArticle {
                ArticleReaderView(article: article) { slug in
                    if let target = selectedTopic?.article(for: slug) {
                        selectedArticle = target
                    }
                }
            } else {
                ContentUnavailableView(
                    "Select an Article",
                    systemImage: "doc.text",
                    description: Text("Choose an article to read")
                )
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Refresh", systemImage: "arrow.clockwise") {
                    hub.refresh(at: settings.wikiPath)
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }
        .onAppear { hub.refresh(at: settings.wikiPath) }
        .onChange(of: settings.wikiPath) { _, newPath in
            hub.refresh(at: newPath)
        }
        .onChange(of: selectedTopic) { _, _ in selectedArticle = nil }
    }
}
