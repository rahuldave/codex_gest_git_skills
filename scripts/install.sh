#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: scripts/install.sh /path/to/target/repo" >&2
  exit 2
fi

source_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_root="$1"

if [ ! -d "$target_root" ]; then
  echo "target repo does not exist: $target_root" >&2
  exit 1
fi

mkdir -p "$target_root/.agents/skills"
mkdir -p "$target_root/docs"
mkdir -p "$target_root/templates"
mkdir -p "$target_root/tools"

for skill in "$source_root"/.agents/skills/g*; do
  [ -d "$skill" ] || continue
  rm -rf "$target_root/.agents/skills/$(basename "$skill")"
  cp -R "$skill" "$target_root/.agents/skills/"
done

for doc in "$source_root"/docs/*.md; do
  [ -f "$doc" ] || continue
  cp "$doc" "$target_root/docs/$(basename "$doc")"
done

rm -rf "$target_root/templates"
cp -R "$source_root/templates" "$target_root/templates"

cp "$source_root/tools/gest_mermaid_graph.py" "$target_root/tools/gest_mermaid_graph.py"
chmod +x "$target_root/tools/gest_mermaid_graph.py"

if [ ! -e "$target_root/AGENTS.md" ]; then
  cp "$source_root/AGENTS.template.md" "$target_root/AGENTS.md"
else
  echo "kept existing AGENTS.md; merge AGENTS.template.md manually if needed" >&2
fi

echo "installed Codex/Gest/Git skills into $target_root"
