import SwiftUI
import MarkdownUI

struct ArticleReaderView: View {
    let article: WikiArticle
    let onNavigateSlug: (String) -> Void

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
            processedBody = WikilinkProcessor.resolveWikilinks(in: article.body)
        }
        .environment(\.openURL, OpenURLAction { url in
            if url.scheme == "wikilink", let slug = url.host {
                onNavigateSlug(slug)
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
