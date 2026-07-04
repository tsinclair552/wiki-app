import SwiftUI

struct ArticleListView: View {
    let topic: TopicWiki
    @Binding var selection: WikiArticle?

    var body: some View {
        List(selection: $selection) {
            ForEach(topic.articlesByCategory, id: \.0) { category, articles in
                Section(category) {
                    ForEach(articles) { article in
                        ArticleRowView(article: article)
                            .tag(article as WikiArticle?)
                    }
                }
            }
        }
        .navigationTitle(topic.title)
    }
}

private struct ArticleRowView: View {
    let article: WikiArticle

    var body: some View {
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
    }
}
