# Wiki Reader — Desktop GUI App Design

> A native macOS SwiftUI application for browsing and reading an LLM-compiled local wiki hub.

## Architecture

**Pattern:** NavigationSplitView with three columns (Topics → Articles → Reader)

**Stack:** SwiftUI (macOS 14+), MarkdownUI, FileManager-only I/O (no server, no database)

**Data flow:** Filesystem → Model layer → Published properties → SwiftUI views

## Navigation Layout

```
┌─────────────────────────────────────────────────────────┐
│ HUB: ~/wiki                                              │
├──────────┬──────────────────┬────────────────────────────┤
│  Topics  │   Articles       │   Article Content          │
│          │                  │                            │
│  ● MI    │  Topics:         │  Michigan Clean Energy...   │
│    RE    │  ┌──────────────┐│  ──────────────────────    │
│          │  │ MI RE Land-  ││  ## Abstract              │
│          │  │ scape        ││  In November 2023...      │
│  ● CO    │  └──────────────┘│                            │
│    RE    │                  │  ## Key Legislation        │
│          │  Concepts:       │                            │
│  ● Local │  ┌──────────────┐│  ### Public Act 235       │
│    AI    │  │ Clean Energy ││  - 100% clean by 2040    │
│          │  │ Standards    ││  - 60% renewable by 2035  │
│          │  └──────────────┘│                            │
│          │  ┌──────────────┐│  ## See Also              │
│          │  │ Siting       ││  [[wikilink]] (link.md)    │
│          │  │ Conflict     │└────────────────────────────┘
├──────────┴──────────────────┴────────────────────────────┤
│  Status: 3 topics · 15 articles · ~/wiki                  │
└─────────────────────────────────────────────────────────┘
```

## Data Model

### WikiHub
- Reads `wikis.json` from hub root to discover topic wikis
- Scans `topics/` directory for `_index.md` / `config.md` to validate
- Property: `topics: [TopicWiki]`

### TopicWiki
- Reads `config.md` frontmatter for title/scope/tags
- Reads `wiki/_index.md` to discover articles grouped by category
- Groups: Concepts, Topics, References, Theses
- Property: `articles: [WikiArticle]`

### WikiArticle
- Reads `.md` file, parses YAML frontmatter (title, category, tags, summary, confidence, sources, aliases)
- Separates frontmatter from body markdown
- Cross-references (`[[wikilink]]`) stored in body, processed at render time

### WikiFileService
- FileManager I/O abstraction
- `func discoverHub(at path: String) -> WikiHub?`
- `func readArticle(at path: String) -> WikiArticle?`
- `func path(for wikiPath: String) -> URL`

## Reading Flow

```
App launch → FileManager reads wikis.json
  → For each topic reads config.md + wiki/_index.md
  → Populates sidebar topics
  → User selects topic → lazy-reads wiki/<category>/*.md
  → Parses frontmatter + body → renders in reader pane
  → User clicks wikilink → navigate to target article
```

No caching for v1 — all reads hit disk. Datasets are small (dozens of files), so performance is instant.

## Markdown Rendering

### Frontmatter Display
YAML frontmatter rendered as metadata header above article body:
- Confidence badge (high/medium/low)
- Tags as pill-style labels
- Source count
- Last updated date

### Body Rendering
Use **MarkdownUI** Swift package for GFM rendering (tables, code blocks, headings, lists, links). Before passing body text to MarkdownUI, a pre-processor converts wikilinks to standard markdown links:

`[[slug|Name]]` → `[Name](wikilink://slug)` and WikilinkProcessor registers a custom `OpenURLAction` that intercepts the `wikilink://` scheme, resolves `slug` to the target article path, and triggers navigation.

Resolution: `slug` is looked up in the current topic's article index (matching against filename stems and `aliases` frontmatter).

## Settings

- Wiki path stored in `UserDefaults` (default: `~/wiki/`)
- Settings panel with folder picker (`.fileImporter`)
- Refresh button (`cmd+R`) — re-reads hub and topics
- No auto-refresh file watcher in v1

## Project Structure

```
wiki-app/
├── wiki-app.xcodeproj
├── Package.swift                    # Dependencies: MarkdownUI
├── Sources/
│   └── WikiApp/
│       ├── WikiApp.swift            # @main entry
│       ├── ContentView.swift        # NavigationSplitView
│       ├── Models/
│       │   ├── WikiHub.swift
│       │   ├── TopicWiki.swift
│       │   └── WikiArticle.swift
│       ├── Views/
│       │   ├── TopicListView.swift
│       │   ├── ArticleListView.swift
│       │   ├── ArticleReaderView.swift
│       │   └── SettingsView.swift
│       ├── Services/
│       │   └── WikiFileService.swift
│       └── Utilities/
│           ├── FrontmatterParser.swift
│           └── WikilinkProcessor.swift
└── Resources/
    └── Assets.xcassets
```

## Dependencies

- **MarkdownUI** (Swift Package) — native GFM markdown rendering for SwiftUI
- **Yams** (Swift Package) — structured YAML frontmatter parsing
- No other external dependencies

## v1 Boundaries

Not included in v1:
- Full-text search across wikis
- Research/new topic creation
- Inline editing
- Network calls
- On-disk caches or indices
- `.wiki/` local project support
- File watching / auto-refresh
- Archived topic support

## Future Extension Points

- **Search:** Add a SearchService + SearchResultsView. Full-text grep over markdown files.
- **Research:** Shell out to OpenCode or the wiki-manager skills to trigger research.
- **Local .wiki/:** Add a "Open Project Wiki" option that looks for `.wiki/` in subdirectories.
- **Multi-hub:** Let users switch between different wiki hub paths.
