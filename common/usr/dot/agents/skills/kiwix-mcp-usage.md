---
name: kiwix-mcp-usage
description: Lookup references for verifiable information from local sources like Wikipedia, StackOverflow via kiwix-mcp server
disable-model-invocation: false
---

# Kiwix MCP Skill

> Query local, offline knowledge bases (Wikipedia, Stack Overflow, etc.) via the Kiwix MCP (Model Context Protocol) server.

## When to Use This MCP

- **Verifying facts** — query Wikipedia for accurate dates, names, historical context, and general reference info.
- **Finding technical solutions** — search Stack Overflow for existing answers to programming errors and debugging questions.

> Skip this skill for speculative advice, opinion-based queries, or anything requiring real-time/live data.

## Correct Workflow (3 Steps)

**Always follow this order — skipping step 1 will fail on multi-book servers.**

### Step 1: List books

```
kiwix_list_books
```

Returns available ZIM files with their unique **slugs**. Example slugs:

- `wikipedia_en_all_nopic_2026-06` (Wikipedia)
- `stackoverflow.com_en_all_2026-07` (Stack Overflow)
- `serverfault.com_en_all_2026-02` (Server Fault)

> **Tip:** Use the `Summary` column to pick the right book. Default to Wikipedia for factual/historical queries; use Stack Overflow for programming.

### Step 2: Search within a book

```
kiwix_search(book="wikipedia_en_all_nopic_2026-06", query="O.J. Simpson prison")
```

| Param   | Required? | Notes                                     |
| ------- | --------- | ----------------------------------------- |
| `book`  | **Yes**   | Use the slug from Step 1, never the title |
| `query` | **Yes**   | Natural-language search terms             |
| `start` | No        | Pagination offset for large result sets   |

### Step 3: Fetch full article

When a search result has a `url` field, fetch its content:

```
kiwix_fetch_article(url="/content/wikipedia_en_all_nopic_2026-06/O._J._Simpson_robbery_case")
```

Returns plain-text. **Always use the URL from search results — never construct it manually.**

## Key Rules

| Rule                         | Why                                                         |
| ---------------------------- | ----------------------------------------------------------- |
| Always list books first      | `kiwix_list_books` is mandatory on multi-book servers       |
| Pass the slug, not the title | The `book` param expects the exact slug field               |
| Use URLs from search results | Do not guess or construct URLs manually                     |
| Pick the right book          | Wikipedia → general knowledge; Stack Overflow → programming |

## Common Pitfall

> Calling `kiwix_search` without a `book` parameter on multi-book servers **will fail**. Always call `kiwix_list_books` first and pass its slug.
