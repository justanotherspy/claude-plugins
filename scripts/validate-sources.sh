#!/usr/bin/env bash
# Validate every plugin the marketplace lists, fetched from its real source.
#
# `claude plugin validate --strict .` checks the marketplace manifest only; it
# does not fetch the plugins, and it accepted git-subdir URLs the marketplace
# sync later rejected. This script closes both gaps:
#
#   1. Lint the catalog: unique names, required listing fields, and https://
#      URLs for every git-based source.
#   2. Fetch each plugin the way the sync does and run `claude plugin validate`
#      on it: --strict for plugins this account maintains, plain validation
#      (errors only) for external plugins, which carry an `author` entry.
#
# Usage: scripts/validate-sources.sh [marketplace.json]
set -uo pipefail

manifest="${1:-.claude-plugin/marketplace.json}"
root="$(cd "$(dirname "$manifest")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

failures=0
fail() { echo "::error::$*"; failures=$((failures + 1)); }

echo "== Catalog lint"
dupes="$(jq -r '[.plugins[].name] | group_by(.) | map(select(length > 1) | .[0]) | .[]' "$manifest")"
[ -z "$dupes" ] || fail "duplicate plugin names: $dupes"

while IFS=$'\t' read -r name problem; do
  fail "$name: $problem"
done < <(jq -r '
  .plugins[]
  | . as $p
  | (
      (["description", "repository", "license", "category"][]
        | select(($p[.] // "") == "") | "missing \(.)"),
      (select($p.strict != true) | "strict must be true"),
      (select(($p.source | type) == "object"
              and ($p.source.source == "git-subdir" or $p.source.source == "url")
              and (($p.source.url // "") | startswith("https://") | not))
        | "source url must use https:// (got \($p.source.url))"),
      (select(($p.source | type) == "string" and ($p.source | startswith("./") | not))
        | "relative source must start with ./")
    )
  | [$p.name, .] | @tsv
' "$manifest")

echo "== Plugin sources"
# "|" rather than a tab: a tab is IFS whitespace, so an empty field would collapse.
while IFS='|' read -r name kind a b external; do
  dir="$work/$name"
  case "$kind" in
    local)
      dir="$root/${a#./}" ;;
    github)
      git clone -q --depth 1 "https://github.com/$a.git" "$dir" \
        || { fail "$name: clone of github:$a failed"; continue; } ;;
    git-subdir)
      git clone -q --depth 1 "$a" "$dir" \
        || { fail "$name: clone of $a failed"; continue; }
      dir="$dir/$b" ;;
    url)
      git clone -q --depth 1 "$a" "$dir" \
        || { fail "$name: clone of $a failed"; continue; } ;;
    *)
      fail "$name: unsupported source type '$kind'"; continue ;;
  esac

  [ -f "$dir/.claude-plugin/plugin.json" ] \
    || { fail "$name: no .claude-plugin/plugin.json at its source"; continue; }

  got="$(jq -r '.name' "$dir/.claude-plugin/plugin.json")"
  [ "$got" = "$name" ] || fail "$name: plugin.json is named '$got'"

  # The claude.ai sync skips a plugin with a top-level bin/, even an empty one
  # (bin/.keep), and `claude plugin validate` does not check for it.
  if [ -n "$(git -C "$dir" ls-files -- bin)" ]; then
    fail "$name: ships a top-level bin/ directory, which the marketplace sync rejects"
  fi

  if [ "$external" = "true" ]; then
    echo "-- $name (external, errors only)"
    claude plugin validate "$dir" || fail "$name: validation failed"
  else
    echo "-- $name (strict)"
    claude plugin validate --strict "$dir" || fail "$name: strict validation failed"
  fi
done < <(jq -r '
  .plugins[]
  | (has("author")) as $ext
  | if (.source | type) == "string" then [.name, "local", .source, "", $ext]
    elif .source.source == "github" then [.name, "github", .source.repo, "", $ext]
    elif .source.source == "git-subdir" then [.name, "git-subdir", .source.url, .source.path, $ext]
    elif .source.source == "url" then [.name, "url", .source.url, "", $ext]
    else [.name, (.source.source // "unknown"), "", "", $ext] end
  | map(tostring) | join("|")
' "$manifest")

if [ "$failures" -gt 0 ]; then
  echo "$failures problem(s) found"
  exit 1
fi
echo "All plugin sources valid"
