import Foundation
import Yams

struct FrontmatterParser {
    struct Result {
        let metadata: [String: Any]
        let body: String
    }

    static func parse(_ content: String) -> Result? {
        guard content.hasPrefix("---") else { return nil }

        let withoutFirst = content.dropFirst(3)
        guard let endRange = withoutFirst.range(of: "\n---\n") ?? withoutFirst.range(of: "\n---") else {
            return nil
        }

        let yamlBlock = String(withoutFirst[..<endRange.lowerBound])
        let bodyStart = withoutFirst[endRange.upperBound...]
            .drop(while: { $0 == "\n" || $0 == "\r" })
        let body = String(bodyStart)

        guard let yaml = try? Yams.load(yaml: yamlBlock) as? [String: Any] else {
            return nil
        }

        return Result(metadata: yaml, body: body)
    }
}
