import SwiftUI

struct ContentView: View {
    @Environment(WikiSettings.self) private var settings
    @State private var hub = WikiHub()
    @State private var selectedTopicID: TopicWiki.ID?
    @State private var selectedArticleID: WikiArticle.ID?

    private var selectedTopic: TopicWiki? {
        hub.topics.first { $0.id == selectedTopicID }
    }

    private var selectedArticle: WikiArticle? {
        selectedTopic?.articles.first { $0.id == selectedArticleID }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTopicID) {
                ForEach(hub.topics) { topic in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(topic.title)
                            .font(.headline)
                        Text("\(topic.articles.count) articles")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .tag(topic.id as TopicWiki.ID?)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Topics")
        } content: {
            if let topic = selectedTopic {
                List(selection: $selectedArticleID) {
                    ForEach(topic.articlesByCategory, id: \.0) { category, articles in
                        Section(category) {
                            ForEach(articles) { article in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(article.title)
                                        .font(.body)
                                    if !article.summary.isEmpty {
                                        Text(article.summary)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                                .tag(article.id as WikiArticle.ID?)
                            }
                        }
                    }
                }
                .navigationTitle(topic.title)
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
                        selectedArticleID = target.id
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
                    selectedTopicID = nil
                    selectedArticleID = nil
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }
        .onAppear { hub.refresh(at: settings.wikiPath) }
        .onChange(of: settings.wikiPath) { _, newPath in
            hub.refresh(at: newPath)
        }
        .onChange(of: selectedTopicID) { _, _ in selectedArticleID = nil }
    }
}
