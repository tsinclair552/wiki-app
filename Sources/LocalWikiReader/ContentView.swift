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
        NavigationSplitView(columnVisibility: .constant(.all)) {
            sidebar
                .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 300)
        } content: {
            contentColumn
                .navigationSplitViewColumnWidth(min: 220, ideal: 280, max: 400)
        } detail: {
            detailColumn
        }
        .toolbar(id: "main") {
            ToolbarItem(id: "refresh", placement: .primaryAction) {
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

    @ViewBuilder
    private var sidebar: some View {
        if hub.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = hub.errorMessage {
            ContentUnavailableView {
                Label("No Topics", systemImage: "tray")
            } description: {
                Text(error)
            }
        } else {
            List(selection: $selectedTopicID) {
                ForEach(hub.topics) { topic in
                    LabeledContent {
                        Text("\(topic.articles.count)")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    } label: {
                        Text(topic.title)
                            .font(.body)
                    }
                    .tag(topic.id as TopicWiki.ID?)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Topics")
        }
    }

    @ViewBuilder
    private var contentColumn: some View {
        if let topic = selectedTopic {
            if topic.articles.isEmpty {
                ContentUnavailableView {
                    Label("No Articles", systemImage: "text.page")
                } description: {
                    Text("This topic has no compiled articles yet.")
                }
            } else {
                List(selection: $selectedArticleID) {
                    ForEach(topic.articlesByCategory, id: \.0) { category, articles in
                        Section(category) {
                            ForEach(articles) { article in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(article.title)
                                        .font(.body)
                                    if !article.summary.isEmpty {
                                        Text(article.summary)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                                .tag(article.id as WikiArticle.ID?)
                            }
                        }
                    }
                }
                .listStyle(.bordered(alternatesRowBackgrounds: true))
                .navigationTitle(topic.title)
            }
        } else {
            ContentUnavailableView {
                Label("Select a Topic", systemImage: "book")
            } description: {
                Text("Choose a wiki topic from the sidebar")
            }
        }
    }

    @ViewBuilder
    private var detailColumn: some View {
        if let article = selectedArticle {
            ArticleReaderView(article: article) { slug in
                if let target = selectedTopic?.article(for: slug) {
                    selectedArticleID = target.id
                }
            }
        } else {
            ContentUnavailableView {
                Label("Select an Article", systemImage: "doc.text")
            } description: {
                Text("Choose an article from the list")
            }
        }
    }
}
