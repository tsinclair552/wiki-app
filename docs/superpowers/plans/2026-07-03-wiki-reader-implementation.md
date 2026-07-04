# Wiki Reader — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a native macOS SwiftUI app that browses topic wikis from a local wiki hub and renders articles with frontmatter and markdown body.

**Architecture:** Three-column NavigationSplitView (Topics → Articles → Reader). Models read the wiki filesystem via FileManager. MarkdownUI renders article bodies. Custom frontmatter and wikilink parsers handle wiki-specific formatting.

**Tech Stack:** Swift 5.9, macOS 14+, SwiftUI, Observation framework, MarkdownUI (SPM), Yams (SPM)

---

## File Structure

```
wiki-app/
├── Package.swift
└── Sources/
    └── WikiApp/
        ├── WikiApp.swift                    # @main entry
        ├── ContentView.swift                # NavigationSplitView wire-up
        ├── Models/
        │   ├── WikiHub.swift                # Hub model — discovers topics
        │   ├── TopicWiki.swift              # Topic model — owns articles
        │   └── WikiArticle.swift            # Article model — parsed .md file
        ├── Views/
        │   ├── TopicListView.swift          # Column 1: topic list
        │   ├── ArticleListView.swift        # Column 2: articles by category
        │   ├── ArticleReaderView.swift      # Column 3: rendered article
        │   └── SettingsView.swift           # Wiki path configuration
        ├── Services/
        │   └── WikiFileService.swift        # FileManager I/O
        └── Utilities/
            ├── FrontmatterParser.swift      # YAML frontmatter → struct
            └── WikilinkProcessor.swift      # [[slug|Name]] → markdown links
```

### Task 1: Project Setup

**Files:**
- Create: `Package.swift`
- Create: `Sources/WikiApp/WikiApp.swift`

**Package.swift:**

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WikiApp",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.4.0"),
        .package(url: "https://github.com/jpsim/Yams", from: "5.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "WikiApp",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "Yams", package: "Yams"),
            ]
        ),
    ]
)
```

**Sources/WikiApp/WikiApp.swift:**

```swift
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
```

### Task 2: Frontmatter Parser

**Files:**
- Create: `Sources/WikiApp/Utilities/FrontmatterParser.swift`

```swift
import Foundation
import Yams

struct FrontmatterParser {
    struct Result {
        let metadata: [String: Any]
        let body: String
    }

    static func parse(_ content: String) -> Result? {
        let lines = content
        guard lines.hasPrefix("---") else { return nil }

        let withoutFirst = lines.dropFirst(3)
        guard let endRange = withoutFirst.range(of: "\n---") ?? withoutFirst.range(of: "\n---\n") else {
            return nil
        }

        let yamlBlock = String(withoutFirst[..<endRange.lowerBound])
        let bodyStart = withoutFirst[endRange.upperBound...]
            .drop(while: { $0 == "\n" || $0 == "\r" })
        let body = String(bodyStart).trimmingCharacters(in: .whitespacesAndNewlines)

        guard let yaml = try? Yams.load(yaml: yamlBlock) as? [String: Any] else {
            return nil
        }

        return Result(metadata: yaml, body: body)
    }
}
```

### Task 3: Wikilink Processor

**Files:**
- Create: `Sources/WikiApp/Utilities/WikilinkProcessor.swift`

```swift
import Foundation

struct WikilinkProcessor {
    static func resolveWikilinks(in body: String, articles: [WikiArticle]) -> String {
        let pattern = /\[\[([^|\[\]]+)(?:\|([^\[\]]+))?\]\]/
        return body.replacing(pattern) { match in
            let slug = String(match.1).trimmingCharacters(in: .whitespaces)
            let display = match.2.map { String($0).trimmingCharacters(in: .whitespaces) } ?? slug
            // Match against filename stem or aliases
            let matched = articles.first { article in
                let stem = URL(fileURLWithPath: article.path).deletingPathExtension().lastPathComponent
                return stem == slug || article.aliases.contains(slug)
            }
            if matched != nil {
                return "[\(display)](wikilink://\(slug))"
            } else {
                return "[\(display)](wikilink://\(slug))"
            }
        }
    }
}
```

### Task 4: WikiFileService

**Files:**
- Create: `Sources/WikiApp/Services/WikiFileService.swift`

```swift
import Foundation

struct WikiFileService {
    let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func contentsOfDirectory(at url: URL) -> [URL] {
        (try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? []
    }

    func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }

    func readString(from url: URL) -> String? {
        try? String(contentsOf: url, encoding: .utf8)
    }

    func discoverTopicWikis(at hubPath: String) -> [URL] {
        let hubURL = URL(fileURLWithPath: (hubPath as NSString).expandingTildeInPath)
        let topicsURL = hubURL.appendingPathComponent("topics")
        guard fileManager.fileExists(atPath: topicsURL.path) else { return [] }
        return contentsOfDirectory(at: topicsURL)
            .filter { isDirectory($0) }
            .filter { fileExists(at: $0.appendingPathComponent("_index.md")) }
    }

    func readConfig(at url: URL) -> [String: Any]? {
        let configURL = url.appendingPathComponent("config.md")
        guard let content = readString(from: configURL),
              let result = FrontmatterParser.parse(content) else { return nil }
        return result.metadata
    }

    func readWikiIndex(at url: URL) -> [String: Any]? {
        let indexURL = url.appendingPathComponent("wiki").appendingPathComponent("_index.md")
        guard let content = readString(from: indexURL),
              let result = FrontmatterParser.parse(content) else { return nil }
        return result.metadata
    }

    func discoverArticleURLs(in topicURL: URL) -> [URL] {
        let wikiDir = topicURL.appendingPathComponent("wiki")
        let categories = ["concepts", "topics", "references", "theses"]
        return categories.flatMap { category -> [URL] in
            let dir = wikiDir.appendingPathComponent(category)
            guard fileManager.fileExists(atPath: dir.path) else { return [] }
            return contentsOfDirectory(at: dir).filter { $0.pathExtension == "md" }
        }
    }

    func readArticleContent(at url: URL) -> (metadata: [String: Any], body: String)? {
        guard let content = readString(from: url),
              let result = FrontmatterParser.parse(content) else { return nil }
        return (result.metadata, result.body)
    }

    private func isDirectory(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        fileManager.fileExists(atPath: url.path, isDirectory: &isDir)
        return isDir.boolValue
    }
}
```

### Task 5: WikiArticle Model

**Files:**
- Create: `Sources/WikiApp/Models/WikiArticle.swift`

```swift
import Foundation

@Observable
final class WikiArticle: Identifiable {
    let path: String
    let title: String
    let category: String
    let tags: [String]
    let summary: String
    let confidence: String
    let aliases: [String]
    let sources: [String]
    let updated: String
    let created: String
    let body: String

    var id: String { path }

    init?(at url: URL, service: WikiFileService) {
        guard let (metadata, rawBody) = service.readArticleContent(at: url) else {
            return nil
        }
        self.path = url.path
        self.title = metadata["title"] as? String ?? url.deletingPathExtension().lastPathComponent
        self.category = metadata["category"] as? String ?? "concept"
        self.tags = metadata["tags"] as? [String] ?? []
        self.summary = metadata["summary"] as? String ?? ""
        self.confidence = metadata["confidence"] as? String ?? "low"
        self.aliases = metadata["aliases"] as? [String] ?? []
        self.sources = metadata["sources"] as? [String] ?? []
        self.updated = metadata["updated"] as? String ?? ""
        self.created = metadata["created"] as? String ?? ""
        self.body = rawBody
    }

    var categoryLabel: String { category.prefix(1).uppercased() + category.dropFirst() }
}
```

### Task 6: TopicWiki Model

**Files:**
- Create: `Sources/WikiApp/Models/TopicWiki.swift`

```swift
import Foundation

@Observable
final class TopicWiki: Identifiable {
    let id: String  // slug
    let path: String
    let title: String
    let scope: String
    let tags: [String]
    var articles: [WikiArticle] = []
    var articlesByCategory: [(String, [WikiArticle])] = []

    var id: String { path }

    init?(at url: URL, service: WikiFileService) {
        let slug = url.lastPathComponent
        self.id = slug
        self.path = url.path

        let config = service.readConfig(at: url)
        self.title = config?["title"] as? String ?? slug
        self.scope = config?["scope"] as? String ?? ""
        self.tags = config?["tags"] as? [String] ?? []
        loadArticles(service: service)
    }

    func loadArticles(service: WikiFileService) {
        let articleURLs = service.discoverArticleURLs(in: URL(fileURLWithPath: path))
        let articles = articleURLs.compactMap { WikiArticle(at: $0, service: service) }
        self.articles = articles

        let grouped = Dictionary(grouping: articles) { $0.categoryLabel }
        let order = ["Concept", "Topic", "Reference", "Thesis"]
        self.articlesByCategory = order.compactMap { cat in
            guard let items = grouped[cat], !items.isEmpty else { return nil }
            return (cat, items)
        }
    }

    func article(for slug: String) -> WikiArticle? {
        let stem = slug.lowercased()
        return articles.first { a in
            let aStem = URL(fileURLWithPath: a.path).deletingPathExtension().lastPathComponent.lowercased()
            return aStem == stem || a.aliases.map { $0.lowercased() }.contains(stem)
        }
    }
}
```

### Task 7: WikiHub Model

**Files:**
- Create: `Sources/WikiApp/Models/WikiHub.swift`

```swift
import Foundation

@Observable
final class WikiHub {
    var topics: [TopicWiki] = []
    var isLoading = false
    var errorMessage: String?

    private let service = WikiFileService()

    func refresh(at path: String) {
        isLoading = true
        errorMessage = nil

        let topicURLs = service.discoverTopicWikis(at: path)
        topics = topicURLs.compactMap { TopicWiki(at: $0, service: service) }

        if topics.isEmpty && !topicURLs.isEmpty {
            errorMessage = "Found topic directories but couldn't read their configs"
        } else if topics.isEmpty {
            errorMessage = "No topic wikis found at this path"
        }
        isLoading = false
    }
}
```

### Task 8: TopicListView

**Files:**
- Create: `Sources/WikiApp/Views/TopicListView.swift`

```swift
import SwiftUI

struct TopicListView: View {
    let topics: [TopicWiki]
    @Binding var selection: TopicWiki?

    var body: some View {
        List(topics, selection: $selection) { topic in
            VStack(alignment: .leading, spacing: 4) {
                Text(topic.title)
                    .font(.headline)
                Text("\(topic.articles.count) articles")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
            .tag(topic as TopicWiki?)
        }
        .navigationTitle("Topics")
    }
}
```

### Task 9: ArticleListView

**Files:**
- Create: `Sources/WikiApp/Views/ArticleListView.swift`

```swift
import SwiftUI

struct ArticleListView: View {
    let topic: TopicWiki
    @Binding var selection: WikiArticle?

    var body: some View {
        List(selection: $selection) {
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
                        .tag(article as WikiArticle?)
                    }
                }
            }
        }
        .navigationTitle(topic.title)
    }
}
```

### Task 10: ArticleReaderView

**Files:**
- Create: `Sources/WikiApp/Views/ArticleReaderView.swift`

```swift
import SwiftUI
import MarkdownUI

struct ArticleReaderView: View {
    let article: WikiArticle
    let allArticles: [WikiArticle]

    @State private var processedBody: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                metadataHeader
                Divider()
                Markdown(processedBody)
                    .textSelection(.enabled)
            }
            .padding(24)
        }
        .navigationTitle(article.title)
        .onAppear {
            processedBody = WikilinkProcessor.resolveWikilinks(
                in: article.body, articles: allArticles
            )
        }
        .environment(\.openURL, OpenURLAction { url in
            if url.scheme == "wikilink" {
                return .handled
            }
            return .systemAction
        })
    }

    @ViewBuilder
    private var metadataHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.largeTitle)
                .bold()

            HStack(spacing: 8) {
                confidenceBadge
                if !article.updated.isEmpty {
                    Label(article.updated, systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if !article.sources.isEmpty {
                    Label("\(article.sources.count) sources", systemImage: "doc.text")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !article.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(article.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.quaternary, in: Capsule())
                    }
                }
            }

            if !article.summary.isEmpty {
                Text(article.summary)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var confidenceBadge: some View {
        let color: Color = switch article.confidence {
        case "high": .green
        case "medium": .orange
        default: .gray
        }
        Label(article.confidence, systemImage: "checkmark.circle.fill")
            .font(.caption)
            .foregroundStyle(color)
    }
}
```

### Task 11: SettingsView

**Files:**
- Create: `Sources/WikiApp/Views/SettingsView.swift`

```swift
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
```

### Task 12: ContentView (NavigationSplitView wire-up)

**Files:**
- Create: `Sources/WikiApp/ContentView.swift`

```swift
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
            if let article = selectedArticle, let topic = selectedTopic {
                ArticleReaderView(article: article, allArticles: topic.articles)
            } else {
                ContentUnavailableView(
                    "Select an Article",
                    systemImage: "doc.text",
                    description: Text("Choose an article to read")
                )
            }
        }
        .onAppear { hub.refresh(at: settings.wikiPath) }
        .onChange(of: settings.wikiPath) { _, newPath in
            hub.refresh(at: newPath)
        }
        .onChange(of: selectedTopic) { _, _ in selectedArticle = nil }
    }
}
```

### Task 13: Verify Build

**Files:** (none — run build)

- [ ] **Build the project**

Run: `swift build`

Expected: Build succeeds with no errors. If MarkdownUI or Yams fetch fails, verify network is available and URLs are correct in Package.swift.

- [ ] **Create Topics directory with sample content for testing**

```bash
mkdir -p ~/wiki/topics/test-topic/wiki/concepts
cat > ~/wiki/topics/test-topic/config.md << 'CONFIG'
---
title: "Test Topic"
scope: "Testing the wiki reader"
tags: [test]
---
CONFIG
cat > ~/wiki/topics/test-topic/wiki/concepts/test-article.md << 'ARTICLE'
---
title: "Test Article"
category: concept
tags: [test, demo]
confidence: high
summary: "A test article for verifying the wiki reader."
aliases: [demo-article]
---
## Hello

This is a **test article** with a [link](https://example.com) and a [[test-article|self reference]].

- List item 1
- List item 2
ARTICLE
```