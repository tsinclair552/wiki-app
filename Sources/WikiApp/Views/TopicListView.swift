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
