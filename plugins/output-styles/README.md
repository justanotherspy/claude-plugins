# output-styles

A collection of [output styles](https://code.claude.com/docs/en/output-styles) for
Claude Code. An output style changes how Claude writes, not what Claude knows.

## Styles

| Style       | Keeps coding instructions | What it does                                                                              |
| ----------- | ------------------------- | ----------------------------------------------------------------------------------------- |
| `ASD-STE100` | yes                       | Writes all prose in Simplified Technical English, adapted from the ASD-STE100 standard. |

### ASD-STE100

[ASD-STE100](https://www.asd-ste100.org/) is the Simplified Technical English
specification the aerospace industry uses so a reader cannot misread an
instruction. This style applies the same discipline to Claude's prose: one
meaning per word, one verb per action, active voice, simple tenses, short
sentences, and lists instead of buried sequences.

Code, commands, file paths, error messages, and quoted text stay verbatim.
Accuracy wins over style — the rules never trim a fact, a condition, or a
qualifier.

## Install

```
/plugin marketplace add justanotherspy/claude-plugins
/plugin install output-styles@justanotherspy
```

## Use

Run `/config`, select **Output style**, and pick `ASD-STE100`. Or set it
directly in a settings file such as `.claude/settings.local.json`. A plugin
style is namespaced with the plugin name, so the value is
`output-styles:ASD-STE100`:

```json
{
  "outputStyle": "output-styles:ASD-STE100"
}
```

The style is part of the system prompt, so it takes effect after `/clear` or in
the next session.
