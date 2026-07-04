import Foundation

@Observable
final class WikiSettings {
    var wikiPath: String {
        didSet {
            if oldValue != wikiPath {
                UserDefaults.standard.set(wikiPath, forKey: "wikiPath")
            }
        }
    }

    init() {
        self.wikiPath = UserDefaults.standard.string(forKey: "wikiPath")
            ?? FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("wiki").path
    }
}
