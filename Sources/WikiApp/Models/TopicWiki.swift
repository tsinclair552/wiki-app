import Foundation

@Observable
final class TopicWiki: Identifiable, Hashable {
    static func == (lhs: TopicWiki, rhs: TopicWiki) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    let id: String
    let path: String
    let title: String
    let scope: String
    let tags: [String]
    var articles: [WikiArticle] = []
    var articlesByCategory: [(String, [WikiArticle])] = []

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
