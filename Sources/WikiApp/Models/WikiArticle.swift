import Foundation

@Observable
final class WikiArticle: Identifiable, Hashable {
    static func == (lhs: WikiArticle, rhs: WikiArticle) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
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
