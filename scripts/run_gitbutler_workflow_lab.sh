#!/usr/bin/env bash
set -euo pipefail

lab="${AGENT_GEST_GITBUTLER_LAB:-/tmp/agent-gest-gitbutler-workflow-lab}"
remote="${AGENT_GEST_GITBUTLER_LAB_REMOTE:-$lab-remote.git}"
worktree_a="$lab-worktree-a"
worktree_b="$lab-worktree-b"

rm -rf "$lab" "$remote" "$worktree_a" "$worktree_b"
mkdir -p "$lab"
git init --bare --initial-branch=main "$remote" >/dev/null
cd "$lab"

git init -b main >/dev/null
git config user.name "workflow-test"
git config user.email "workflow-test@example.invalid"
git remote add origin "$remote"
printf '# GitButler Workflow Lab\n' > README.md
mkdir -p src
printf 'base\n' > src/app.txt
git add README.md src/app.txt
git commit -m "chore: initialize GitButler workflow lab" >/dev/null
git push -u origin main >/dev/null

but setup >/dev/null

remote_has_branch() {
  git ls-remote --exit-code --heads origin "$1" >/dev/null
}

commit_count_from_main() {
  git fetch origin "$1:$1-check" >/dev/null 2>&1 || true
  git rev-list --count "origin/main..$1-check"
}

echo "Flow 1: plain GitButler branch review flow"
but branch new demo/plain-branch >/dev/null
printf 'plain branch change\n' > plain.txt
but commit demo/plain-branch -m "test: add plain branch change" >/dev/null
but push demo/plain-branch >/dev/null
remote_has_branch demo/plain-branch || {
  echo "expected demo/plain-branch on origin" >&2
  exit 1
}

echo "Flow 2: multi-commit GitButler session branch flow"
but branch new demo/multi-commit >/dev/null
printf 'session edit one\n' > session.txt
but commit demo/multi-commit -m "test: add first session edit" >/dev/null
printf 'session edit two\n' >> session.txt
but commit demo/multi-commit -m "test: add second session edit" >/dev/null
but push demo/multi-commit >/dev/null
remote_has_branch demo/multi-commit || {
  echo "expected demo/multi-commit on origin" >&2
  exit 1
}
session_count="$(commit_count_from_main demo/multi-commit)"
if [ "$session_count" -lt 2 ]; then
  echo "expected at least two commits in multi-commit flow" >&2
  exit 1
fi

echo "Flow 3: stacked GitButler branch flow"
but branch new demo/stack-base >/dev/null
printf 'stack base\n' > stack.txt
but commit demo/stack-base -m "test: add stack base" >/dev/null
but branch new --anchor demo/stack-base demo/stack-child >/dev/null
printf 'stack child\n' >> stack.txt
but commit demo/stack-child -m "test: add stack child" >/dev/null
but push demo/stack-base >/dev/null
but push demo/stack-child >/dev/null
remote_has_branch demo/stack-base || {
  echo "expected demo/stack-base on origin" >&2
  exit 1
}
remote_has_branch demo/stack-child || {
  echo "expected demo/stack-child on origin" >&2
  exit 1
}
stack_count="$(commit_count_from_main demo/stack-child)"
if [ "$stack_count" -lt 2 ]; then
  echo "expected stacked child branch to contain base and child commits" >&2
  exit 1
fi

echo "Flow 4: parallel physical git worktrees"
but teardown >/dev/null 2>&1 || true
git checkout main >/dev/null
GEST_VCS_EXECUTION=git-worktrees git worktree add -b demo/worktree-a "$worktree_a" main >/dev/null
GEST_VCS_EXECUTION=git-worktrees git worktree add -b demo/worktree-b "$worktree_b" main >/dev/null

(
  cd "$worktree_a"
  printf 'worktree a isolated change\n' > worktree-a.txt
  git add worktree-a.txt
  git commit -m "test: add worktree a change" >/dev/null
  git push -u origin demo/worktree-a >/dev/null
)

(
  cd "$worktree_b"
  printf 'worktree b isolated change\n' > worktree-b.txt
  git add worktree-b.txt
  git commit -m "test: add worktree b change" >/dev/null
  git push -u origin demo/worktree-b >/dev/null
)

remote_has_branch demo/worktree-a || {
  echo "expected demo/worktree-a on origin" >&2
  exit 1
}
remote_has_branch demo/worktree-b || {
  echo "expected demo/worktree-b on origin" >&2
  exit 1
}

git worktree remove "$worktree_a" >/dev/null
git worktree remove "$worktree_b" >/dev/null

if git worktree list | grep -q 'agent-gest-gitbutler-workflow-lab-worktree-'; then
  echo "expected demo worktrees to be removed" >&2
  exit 1
fi

git status --short --branch >/dev/null
echo "GitButler workflow lab passed: $lab"
