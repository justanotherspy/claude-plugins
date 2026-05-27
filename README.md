# claude-plugins

The central [Claude Code](https://code.claude.com) plugin marketplace for
[justanotherspy](https://github.com/justanotherspy). Each plugin's definition
lives in its own project repo (project + skills together); this repo's
`.claude-plugin/marketplace.json` catalogs them and points at where to fetch
each one.

## Plugins

| Plugin   | Source repo                                                   | What it does                                                                                          |
| -------- | ------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `shuck`  | [`justanotherspy/shuck`](https://github.com/justanotherspy/shuck)   | Exact failing CI step logs for a GitHub PR — a `/shuck` skill plus a local MCP server.          |
| `garlic` | [`justanotherspy/garlic`](https://github.com/justanotherspy/garlic) | Ward off AI burnout — tracks active Claude Code time via hooks and nudges breaks, plus `/garlic`. |
| `sproot` | [`justanotherspy/sproot`](https://github.com/justanotherspy/sproot) | Author and convert `sproot.yaml` configs — `/sproot:script-convert` + `/sproot:author-config` skills. |

Each entry uses a [`git-subdir`](https://code.claude.com/docs/en/plugin-marketplaces#git-subdirectories)
source so the plugin is fetched straight from its home repo (e.g.
`plugins/shuck` inside `justanotherspy/shuck`).

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

1. Build the plugin inside its project repo (a directory with
   `.claude-plugin/plugin.json`, e.g. `plugins/<name>/`).
2. Add an entry to `.claude-plugin/marketplace.json` here, sourcing it via
   `git-subdir` (or `github` if the plugin is at the repo root).
3. Validate with `claude plugin validate .`, then push.
