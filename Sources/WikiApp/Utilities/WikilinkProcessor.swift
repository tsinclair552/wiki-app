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
