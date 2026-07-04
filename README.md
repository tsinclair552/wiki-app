# LocalWiki Reader

**Pre-pre-alpha. Not for real work.**

This is a native macOS app (SwiftUI, macOS 14+) for browsing a local wiki compiled by [llm-wiki](https://llm-wiki.net) — the LLM-compiled knowledge base system. It reads markdown files directly from disk in the `~/wiki/topics/<name>/` layout produced by llm-wiki's `wiki-manager` skills.

**This is NOT a Wikipedia client.** It does not access or display content from Wikipedia. It reads local wiki content formatted for LLM-based compilation workflows.

## Status

Very early development. Expect rough edges, missing features, and breaking changes. Do not rely on this for anything important.

- Topics and articles listed from a hub path (default: `~/wiki`)
- Article rendering with markdown support, frontmatter metadata, confidence badges
- Obsidian-style `[[wikilink]]` cross-reference navigation within topics
- Manual refresh (⌘R) — no file watching yet

## Requirements

- macOS 14 (Sonoma) or later
- An llm-wiki hub at `~/wiki` with topic sub-wikis

## Build

```bash
swift build -c release
```

Or use `Scripts/package.sh` for a full `.app` bundle build.

## License

MIT
