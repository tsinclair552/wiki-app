import SwiftUI
import MarkdownUI

struct ArticleReaderView: View {
    let article: WikiArticle
    let onNavigateSlug: (String) -> Void

    @State private var processedBody: String = ""
    @State private var showMetadata = true
    @AppStorage("readerTextSize") private var textSize: Double = 14

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if showMetadata {
                    metadataHeader
                        .padding(.horizontal)
                        .padding(.top, 24)
                        .padding(.bottom, 16)

                    Divider()
                        .padding(.horizontal)
                }

                Markdown(processedBody)
                    .textSelection(.enabled)
                    .markdownTheme(MarkdownUI.Theme.gitHub)
                    .padding(.horizontal)
                    .padding(.top, showMetadata ? 16 : 24)
                    .padding(.bottom, 40)
            }
            .frame(maxWidth: 680, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
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
        .toolbar(id: "reader") {
            ToolbarItem(id: "metadata-toggle") {
                Button(showMetadata ? "Hide Info" : "Show Info", systemImage: showMetadata ? "info.circle.fill" : "info.circle") {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showMetadata.toggle()
                    }
                }
            }
            ToolbarItem(id: "text-smaller") {
                Button("Smaller", systemImage: "textformat.size.smaller") {
                    textSize = max(11, textSize - 1)
                }
            }
            ToolbarItem(id: "text-larger") {
                Button("Larger", systemImage: "textformat.size.larger") {
                    textSize = min(20, textSize + 1)
                }
            }
        }
    }

    @ViewBuilder
    private var metadataHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.system(size: textSize + 10, weight: .bold, design: .serif))
                .textSelection(.enabled)

            HStack(spacing: 12) {
                confidenceBadge
                if !article.updated.isEmpty {
                    Label(article.updated, systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if !article.sources.isEmpty {
                    Label("\(article.sources.count) source\(article.sources.count == 1 ? "" : "s")", systemImage: "doc.text")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !article.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(article.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
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
                    .padding(.top, 4)
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

