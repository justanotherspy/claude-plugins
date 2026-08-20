# claude-plugins

The central [Claude Code](https://code.claude.com) plugin marketplace for
[justanotherspy](https://github.com/justanotherspy). A plugin backed by a
project lives in its own project repo (project + skills together); standalone
plugins live in `plugins/` here. This repo's `.claude-plugin/marketplace.json`
catalogs them all and points at where to fetch each one.

## Plugins

| Plugin          | Source                                                              | What it does                                                                                          |
| --------------- | ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `shuck`         | [`justanotherspy/shuck`](https://github.com/justanotherspy/shuck)   | Exact failing CI step logs for a GitHub PR — a `/shuck` skill plus a local MCP server.          |
| `garlic`        | [`justanotherspy/garlic`](https://github.com/justanotherspy/garlic) | Ward off AI burnout — tracks active Claude Code time via hooks and nudges breaks, plus `/garlic`. |
| `sproot`        | [`justanotherspy/sproot`](https://github.com/justanotherspy/sproot) | Author and convert `sproot.yaml` configs — `/sproot:script-convert` + `/sproot:author-config` skills. |
| `output-styles` | [`plugins/output-styles`](plugins/output-styles)                    | Output styles for Claude Code — currently `ASD-STE100`, Simplified Technical English for prose. |

A plugin hosted in its own repo uses a [`git-subdir`](https://code.claude.com/docs/en/plugin-marketplaces#git-subdirectories)
source, so the plugin is fetched straight from that repo (e.g.
`plugins/shuck` inside `justanotherspy/shuck`). A plugin hosted here uses a
relative path source (e.g. `./plugins/output-styles`).

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
2. Add an entry to `.claude-plugin/marketplace.json` here. Source it via
   `git-subdir` (or `github` if the plugin is at the repo root) for a plugin in
   another repo, or via a relative path such as `./plugins/<name>` for one
   hosted here.
3. Validate with `claude plugin validate .`, then push.
