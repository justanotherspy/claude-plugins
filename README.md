# claude-plugins

The central [Claude Code](https://code.claude.com) plugin marketplace for
[justanotherspy](https://github.com/justanotherspy). A plugin backed by a
project lives in its own project repo (project + skills together); standalone
plugins live in `plugins/` here. This repo's `.claude-plugin/marketplace.json`
catalogs them all and points at where to fetch each one.

## Plugins

| Plugin          | Source                                                              | What it does                                                                                          |
| --------------- | ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `shuck`         | [`justanotherspy/shuck`](https://github.com/justanotherspy/shuck)   | A background monitor on the PR for your working tree — new CI failures with their exact failing step logs, review comments with code context, and stale GitHub Action pins, as they happen. Plus the `/shuck` skill on demand. Needs the `shuck` binary on PATH. |
| `garlic`        | [`justanotherspy/garlic`](https://github.com/justanotherspy/garlic) | Ward off AI burnout — tracks active Claude Code time via hooks and nudges breaks, plus `/garlic status`. Needs the `garlic` binary on PATH (`cargo install garlic-ward`). |
| `sproot`        | [`justanotherspy/sproot`](https://github.com/justanotherspy/sproot) | Author and convert `sproot.yaml` configs — `/sproot:script-convert` + `/sproot:author-config` skills. |
| `humanizer`     | [`blader/humanizer`](https://github.com/blader/humanizer)           | Rewrite AI-sounding text so it reads naturally without changing what it says (external plugin, maintained by blader). |
| `hey`           | [`justanotherspy/hey-cli`](https://github.com/justanotherspy/hey-cli) | HEY email, calendars, todos, journal and time tracking from Claude Code (external plugin, maintained by 37signals). Needs the `hey` binary on PATH. |
| `output-styles` | [`plugins/output-styles`](plugins/output-styles)                    | Output styles for Claude Code — currently `ASD-STE100`, Simplified Technical English for prose. |

## How sources are declared

Every entry uses the source type that matches where the plugin actually lives,
per the [plugin marketplace reference](https://code.claude.com/docs/en/plugin-marketplaces):

| Where the plugin lives                      | Source type                                                                                                   | Used by                      |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| A subdirectory of another repo              | [`git-subdir`](https://code.claude.com/docs/en/plugin-marketplaces#git-subdirectories) with an `https://` `url` + `path` | `shuck`, `garlic`, `sproot`  |
| The root of another repo                    | `github` with `repo`                                                                                            | `humanizer`, `hey`           |
| This repo                                   | A relative path starting with `./`                                                                              | `output-styles`              |

`git-subdir` does a partial clone (`--filter=tree:0`) and materializes only the
named subdirectory, so pulling `plugins/shuck` does not download the rest of
the `shuck` repo.

Two deliberate choices:

- **No refs are pinned.** Each source tracks its repo's default branch, so
  `/plugin update` always fetches the current plugin. `git-subdir`, `github`
  and `url` sources all accept an optional `ref` (branch or tag) or `sha`
  (full 40-character commit) if an entry ever needs freezing.
- **Versions live in each plugin's own manifest.** Every entry sets
  `"strict": true`, so the plugin's `.claude-plugin/plugin.json` is required
  and is the single source of truth for its version. The marketplace entry
  carries only listing metadata (description, repository, license, category,
  keywords), which cannot drift out of sync with an upstream release.

The marketplace manifest references its [SchemaStore](https://www.schemastore.org)
schema via `$schema`, so editors validate and autocomplete it. Plugin manifests
leave `$schema` out: the marketplace sync flags it as an unrecognized key.

## Install

Add the marketplace once:

```
/plugin marketplace add justanotherspy/claude-plugins
```

Then install the plugins you want:

```
/plugin install shuck@justanotherspy
/plugin install garlic@justanotherspy
/plugin install sproot@justanotherspy
/plugin install humanizer@justanotherspy
/plugin install hey@justanotherspy
/plugin install output-styles@justanotherspy
```

To enable plugins automatically for a repo, add them to that repo's
`.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "justanotherspy": {
      "source": { "source": "github", "repo": "justanotherspy/claude-plugins" }
    }
  },
  "enabledPlugins": {
    "shuck@justanotherspy": true
  }
}
```

## Adding a plugin

1. Build the plugin as a directory with `.claude-plugin/plugin.json`. Put it in
   its project repo (e.g. `plugins/<name>/` there) when a project backs it, or
   in `plugins/<name>/` here when it stands alone.
2. Add an entry to `.claude-plugin/marketplace.json` here, picking the source
   type from the table above.
3. Validate with `claude plugin validate --strict .` and
   `scripts/validate-sources.sh`, then push.

CI (`.github/workflows/validate-marketplace.yml`) runs both on every pull
request that touches `.claude-plugin/`, `plugins/` or `scripts/`, on pushes to
`main`, and daily, since external sources change without a commit here.
`validate-sources.sh` lints the catalog (unique names, required listing fields,
`strict: true`, `https://` URLs for git sources, which the marketplace sync
requires and the manifest validator does not check), then fetches each plugin
from its real source and validates it: `--strict` for plugins maintained here,
errors only for external plugins (entries with an `author`).
