import SwiftUI
import MarkdownUI

struct ArticleReaderView: View {
    let article: WikiArticle
    let onNavigateSlug: (String) -> Void

    @Environment(\.colorScheme) private var scheme
    @State private var processedBody: String = ""
    @State private var showMetadata = true
    @AppStorage("readerTextSize") private var textSize: Double = 14

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if showMetadata {
                    metadataHeader
                        .padding(.horizontal, AD.S.lg)
                        .padding(.top, AD.S.lg)
                        .padding(.bottom, AD.S.md)

                    Divider()
                        .overlay(AD.hairlineColor(scheme))
                        .padding(.horizontal, AD.S.lg)
                }

                Markdown(processedBody)
                    .textSelection(.enabled)
                    .markdownTheme(AD.readerTheme(baseSize: textSize, scheme: scheme))
                    .padding(.horizontal, AD.S.lg)
                    .padding(.top, showMetadata ? AD.S.md : AD.S.lg)
                    .padding(.bottom, AD.S.xxl)
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
                Button(showMetadata ? "Hide Info" : "Show Info",
                       systemImage: showMetadata ? "info.circle.fill" : "info.circle") {
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
        VStack(alignment: .leading, spacing: AD.S.sm) {
            Text(article.title)
                .font(AD.display(textSize + 10))
                .tracking(-0.3)
                .foregroundStyle(AD.inkColor(scheme))
                .textSelection(.enabled)

            if !article.summary.isEmpty {
                Text(article.summary)
                    .font(AD.lead(textSize))
                    .foregroundStyle(AD.inkMuted80(scheme))
                    .padding(.top, AD.S.xxs)
                    .textSelection(.enabled)
            }

            HStack(spacing: AD.S.sm) {
                confidenceBadge
                if !article.updated.isEmpty {
                    Label(article.updated, systemImage: "calendar")
                        .font(AD.caption)
                        .foregroundStyle(AD.inkMuted48(scheme))
                }
                if !article.sources.isEmpty {
                    Label("\(article.sources.count) source\(article.sources.count == 1 ? "" : "s")",
                          systemImage: "doc.text")
                        .font(AD.caption)
                        .foregroundStyle(AD.inkMuted48(scheme))
                }
            }
            .padding(.top, AD.S.xxs)

            if !article.tags.isEmpty {
                HStack(spacing: AD.S.xxs) {
                    ForEach(article.tags, id: \.self) { tag in
                        Text(tag)
                            .font(AD.caption)
                            .foregroundStyle(AD.inkMuted80(scheme))
                            .padding(.horizontal, AD.S.sm)
                            .padding(.vertical, AD.S.xxs + 1)
                            .background(
                                AD.surface(scheme, .pearl),
                                in: RoundedRectangle(cornerRadius: AD.R.md)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AD.R.md)
                                    .stroke(AD.hairlineColor(scheme), lineWidth: 0.5)
                            )
                    }
                }
                .padding(.top, AD.S.xxs)
            }
        }
    }

    @ViewBuilder
    private var confidenceBadge: some View {
        let color = AD.confidenceColor(article.confidence)
        Text(article.confidence.capitalized)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, AD.S.xs)
            .padding(.vertical, AD.S.xxs)
            .background(color.opacity(0.12), in: Capsule())
    }
}
