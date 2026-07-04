import SwiftUI

struct ContentView: View {
    @Environment(WikiSettings.self) private var settings
    @Environment(\.colorScheme) private var scheme
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
        let bg = AD.surface(scheme, .sidebar)
        if hub.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(bg)
        } else if let error = hub.errorMessage {
            ContentUnavailableView {
                Label("No Topics", systemImage: "tray")
            } description: {
                Text(error)
            }
            .background(bg)
        } else {
            List(selection: $selectedTopicID) {
                ForEach(hub.topics) { topic in
                    LabeledContent {
                        Text("\(topic.articles.count)")
                            .font(AD.caption)
                            .foregroundStyle(AD.inkMuted48(scheme))
                    } label: {
                        Text(topic.title)
                            .font(AD.bodyStrong)
                            .foregroundStyle(AD.inkColor(scheme))
                    }
                    .tag(topic.id as TopicWiki.ID?)
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .background(bg)
            .navigationTitle("Topics")
        }
    }

    @ViewBuilder
    private var contentColumn: some View {
        let bg = AD.surface(scheme, .content)
        if let topic = selectedTopic {
            if topic.articles.isEmpty {
                ContentUnavailableView {
                    Label("No Articles", systemImage: "text.page")
                } description: {
                    Text("This topic has no compiled articles yet.")
                }
                .background(bg)
            } else {
                List(selection: $selectedArticleID) {
                    ForEach(topic.articlesByCategory, id: \.0) { category, articles in
                        Section(category) {
                            ForEach(articles) { article in
                                VStack(alignment: .leading, spacing: AD.S.xxs) {
                                    Text(article.title)
                                        .font(AD.bodyStrong)
                                        .foregroundStyle(AD.inkColor(scheme))
                                    if !article.summary.isEmpty {
                                        Text(article.summary)
                                            .font(AD.caption)
                                            .foregroundStyle(AD.inkMuted48(scheme))
                                            .lineLimit(2)
                                    }
                                }
                                .padding(.vertical, AD.S.xxs)
                                .tag(article.id as WikiArticle.ID?)
                            }
                        }
                    }
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
                .background(bg)
                .navigationTitle(topic.title)
            }
        } else {
            ContentUnavailableView {
                Label("Select a Topic", systemImage: "book")
            } description: {
                Text("Choose a wiki topic from the sidebar")
            }
            .background(bg)
        }
    }

    @ViewBuilder
    private var detailColumn: some View {
        let bg = AD.surface(scheme, .reader)
        if let article = selectedArticle {
            ArticleReaderView(article: article) { slug in
                if let target = selectedTopic?.article(for: slug) {
                    selectedArticleID = target.id
                }
            }
            .background(bg)
        } else {
            ContentUnavailableView {
                Label("Select an Article", systemImage: "doc.text")
            } description: {
                Text("Choose an article from the list")
            }
            .background(bg)
        }
    }
}
