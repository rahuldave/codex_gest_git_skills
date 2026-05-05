#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/sync_g_skills.sh [--dry-run] <target-repo>

Sync reusable g* skills from this repository into a target repository's
.agents/skills directory. Non-g* skills in the target are left alone.
USAGE
}

rsync_args=(-a --delete)
dry_run_enabled=0
if [[ "${1:-}" == "--dry-run" ]]; then
  rsync_args+=(--dry-run)
  dry_run_enabled=1
  shift
fi

if [[ $# -ne 1 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
source_skills="$repo_root/.agents/skills"
target_repo="$(cd "$1" && pwd)"
target_skills="$target_repo/.agents/skills"

if [[ "$dry_run_enabled" -eq 0 ]]; then
  mkdir -p "$target_skills"
elif [[ ! -d "$target_skills" ]]; then
  echo "Would create $target_skills"
fi

for source_dir in "$source_skills"/g*; do
  [[ -d "$source_dir" ]] || continue
  skill_name="$(basename "$source_dir")"
  if [[ "$dry_run_enabled" -eq 0 ]]; then
    mkdir -p "$target_skills/$skill_name"
  elif [[ ! -d "$target_skills/$skill_name" ]]; then
    echo "Would create $target_skills/$skill_name"
    continue
  fi
  rsync "${rsync_args[@]}" "$source_dir/" "$target_skills/$skill_name/"
done

echo "Synced reusable g* skills to $target_skills"
