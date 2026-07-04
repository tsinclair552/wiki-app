import Foundation

struct WikilinkProcessor {
    static func resolveWikilinks(in body: String) -> String {
        var result = ""
        var i = body.startIndex
        while i < body.endIndex {
            if body[i] == "[" && body.index(after: i) < body.endIndex && body[body.index(after: i)] == "[" {
                let contentStart = body.index(i, offsetBy: 2)
                guard let close = body[contentStart...].firstIndex(of: "]"),
                      close < body.index(before: body.endIndex),
                      body[body.index(after: close)] == "]"
                else {
                    result.append(body[i])
                    i = body.index(after: i)
                    continue
                }
                let inner = body[contentStart..<close]
                let parts = inner.split(separator: "|", maxSplits: 1)
                let slug = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let display = parts.count > 1
                    ? String(parts[1]).trimmingCharacters(in: .whitespaces)
                    : slug
                result += "[\(display)](wikilink://\(slug))"
                i = body.index(after: body.index(after: close))
            } else {
                result.append(body[i])
                i = body.index(after: i)
            }
        }
        return result
    }
}
