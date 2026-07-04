import Foundation

struct WikilinkProcessor {
    static func resolveWikilinks(in body: String, articles: [WikiArticle]) -> String {
        let pattern = /\[\[([^|\[\]]+)(?:\|([^\[\]]+))?\]\]/
        return body.replacing(pattern) { match in
            let slug = String(match.1).trimmingCharacters(in: .whitespaces)
            let display = match.2.map { String($0).trimmingCharacters(in: .whitespaces) } ?? slug
            return "[\(display)](wikilink://\(slug))"
        }
    }
}
