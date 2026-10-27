---
name: xerj-usage
description: Search local nixpkgs, nix-darwin, home-manager, and indexed GitHub issues/PRs for Nix implementations and troubleshooting.
---

# Xerj MCP Skill

> Search local Nix reference repos and indexed GitHub issues/PRs with Xerj tools.
> The MCP adapter connects to the existing engine managed by the system service.

## When to Use Xerj

- **Implementations** — packages, options, defaults, merge behavior, and examples.
- **Troubleshooting** — errors, renamed options, regressions, and fixes.
- **Compatibility** — applicability to the project's pinned revision.

> Indexes are snapshots. Use live sources for current status or missing coverage.

## Correct Workflow (3 Steps)

### Step 1: Discover indexes

Call `xerj_map` to discover indexed data:

```json
{ "limit": 20 }
```

The daily `refresh-references` job uses these prefixes:

| Prefix              | Source                                     |
| ------------------- | ------------------------------------------ |
| `refs-nixpkgs`      | Packages, NixOS modules, library functions |
| `refs-nix-darwin`   | macOS system modules                       |
| `refs-home-manager` | User environments and program modules      |
| `refs-metadata`     | GitHub issues/PRs for all three repos      |

**Check the map first:** another machine may use different prefixes or have
different data loaded. Inspect further pages if needed.

### Step 2: Search within a prefix

Call `xerj_search` with a plain-text query:

```json
{ "prefix": "refs-nixpkgs", "query": "services.openssh.settings", "size": 5 }
```

| Argument | Use                                               |
| -------- | ------------------------------------------------- |
| `prefix` | Autoindex prefix, not the full dataset/index name |
| `size`   | Number of hits; start with 5                      |
| `query`  | Exact identifier, error text, or related terms    |
| `index`  | Returned index name; use instead of `prefix`      |

Search source for behavior and issues/PRs for workarounds. Ranking is lexical:
use exact names, then related terms if needed.

For a known identifier, call `xerj_def`:

```json
{ "prefix": "refs-nixpkgs", "symbol": "mkEnableOption", "k": 5 }
```

For errors or regressions, call `xerj_search` with `prefix: "refs-metadata"`.
If definition extraction misses the symbol, use ordinary search or local `rg`.

### Step 3: Verify and cite

Read the returned location and surrounding code when accessible. For issues/PRs,
check discussion, dates, status, and linked commits; fetch the URL if needed.

Compare revisions with the project's lock file or channel. An upstream fix may
not be in the pin; a proposed PR does not establish that it shipped.

**Cite the source path and line or returned GitHub URL.** State any revision or
freshness limits.

## Key Rules

| Rule                                | Why                                       |
| ----------------------------------- | ----------------------------------------- |
| Discover scope first                | Default `ax-*` may miss the relevant data |
| Check revisions and dates           | Evidence may be stale or version-specific |
| Follow returned locators            | Do not invent paths, lines, or links      |
| Verify weak/empty results elsewhere | Coverage and extraction are incomplete    |

## Common Pitfalls

> Use `xerj_map`, `xerj_search`, and `xerj_def` for retrieval. Do not launch the
> server or change indexes; the system service and refresh job manage them.

> Do NOT use the `xerj` cli directly-exclusively use it via the MCP.

> There's NO reason to attempt to use any remote xerj hubs or data. Everything
> you need is locally available.

> The map lists autoindex-catalogued data, not every corpus. An empty map or
> search does not prove that the source lacks the answer.
