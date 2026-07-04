import Foundation

@Observable
final class WikiHub {
    var topics: [TopicWiki] = []
    var isLoading = false
    var errorMessage: String?

    private let service = WikiFileService()

    func refresh(at path: String) {
        isLoading = true
        errorMessage = nil

        let topicURLs = service.discoverTopicWikis(at: path)
        topics = topicURLs.compactMap { TopicWiki(at: $0, service: service) }

        if topics.isEmpty && !topicURLs.isEmpty {
            errorMessage = "Found topic directories but couldn't read their configs"
        } else if topics.isEmpty {
            errorMessage = "No topic wikis found at this path"
        }
        isLoading = false
    }
}
