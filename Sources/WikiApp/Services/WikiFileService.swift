import Foundation

struct WikiFileService {
    let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func contentsOfDirectory(at url: URL) -> [URL] {
        (try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? []
    }

    func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }

    func readString(from url: URL) -> String? {
        try? String(contentsOf: url, encoding: .utf8)
    }

    func discoverTopicWikis(at hubPath: String) -> [URL] {
        let hubURL = URL(fileURLWithPath: (hubPath as NSString).expandingTildeInPath)
        let topicsURL = hubURL.appendingPathComponent("topics")
        guard fileManager.fileExists(atPath: topicsURL.path) else { return [] }
        return contentsOfDirectory(at: topicsURL)
            .filter { isDirectory($0) }
            .filter { fileExists(at: $0.appendingPathComponent("_index.md")) }
    }

    func readConfig(at url: URL) -> [String: Any]? {
        let configURL = url.appendingPathComponent("config.md")
        guard let content = readString(from: configURL),
              let result = FrontmatterParser.parse(content) else { return nil }
        return result.metadata
    }

    func readWikiIndex(at url: URL) -> [String: Any]? {
        let indexURL = url.appendingPathComponent("wiki").appendingPathComponent("_index.md")
        guard let content = readString(from: indexURL),
              let result = FrontmatterParser.parse(content) else { return nil }
        return result.metadata
    }

    func discoverArticleURLs(in topicURL: URL) -> [URL] {
        let wikiDir = topicURL.appendingPathComponent("wiki")
        let categories = ["concepts", "topics", "references", "theses"]
        return categories.flatMap { category -> [URL] in
            let dir = wikiDir.appendingPathComponent(category)
            guard fileManager.fileExists(atPath: dir.path) else { return [] }
            return contentsOfDirectory(at: dir).filter { $0.pathExtension == "md" }
        }
    }

    func readArticleContent(at url: URL) -> (metadata: [String: Any], body: String)? {
        guard let content = readString(from: url),
              let result = FrontmatterParser.parse(content) else { return nil }
        return (result.metadata, result.body)
    }

    private func isDirectory(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        fileManager.fileExists(atPath: url.path, isDirectory: &isDir)
        return isDir.boolValue
    }
}
