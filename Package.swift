// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WikiApp",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.4.0"),
        .package(url: "https://github.com/jpsim/Yams", from: "5.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "WikiApp",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "Yams", package: "Yams"),
            ]
        ),
    ]
)
