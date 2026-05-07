# Live GitHub GitButler Workflow Tutorial

This tutorial shows four live GitHub workflows for the Git/GitButler skills
repo. It was written after exercising all four flows against private temporary
GitHub repositories on 2026-05-07. The examples were cleaned up with
`gh repo delete --yes`.

Use this document in two ways:

- As user prompts to give Codex when you want it to set up and run these flows.
- As command guidance for agents implementing GitButler-backed Gest work.

## Setup Prompt

Give Codex a setup prompt like this before asking for individual flows:

```text
Use the GitButler Gest workflow. Verify that gh is authenticated for github.com
and has repo plus delete_repo scopes. Create a uniquely named temporary private
GitHub repo for each workflow example, initialize it with git + gh, run
`but setup` for GitButler examples, capture command output for a tutorial trace,
and delete the temp repo with `gh repo delete --yes` during cleanup. While
GitButler owns the workspace, use `but` write commands and do not use raw
`git commit`, `git checkout`, `git switch`, branch-mutating `git branch`, or
raw git reset/rebase/merge/push commands.
```

The live run confirmed `but pr new <branch> -m <title-and-body> --json` is the
current non-interactive PR command shape. On this machine, GitButler forge auth
was not configured, so `but pr new` reported:

```text
No authenticated forge users found.
Run 'but config forge auth' to authenticate with GitHub.
```

When forge auth is configured, prefer `but pr new`. Until then, the reliable
live path is `but push <branch>` followed by `gh pr create`. Keep this
requirement visible in tutorials and scripts.

## Tag And Dependency Prompt

Give Codex this prompt whenever one of the flow tasks changes code behavior:

```text
Before creating the Gest task, collect existing project tags from tasks,
artifacts, and iterations, classify this work against that vocabulary, and tell
me which existing tags you selected, which new dynamic tags you added, and which
near-miss tags you rejected. Then identify changed semantic contracts and run
ast-grep over dependers. If a related surface should change too, expand the task
or create a child task with the same semantic tag before implementing.
```

Worked example using the histogram/pill color coupling:

```text
User asks: change histogram colors for low-count bins.

Classifier should select or create:
- count-or-probability-coloring
- histogram-colors
- probability-pill-colors

Coupled concept:
- the same count/probability color scale is consumed by histogram bins, pills,
  and legends.
```

Example code search:

```bash
ast-grep run --lang javascript   --pattern 'countOrProbabilityColorScale($$$)'   --json=compact src
```

Expected dependers in the tested fixture:

```text
src/histogram.js
src/pill.js
```

That means a histogram-color task should either update the pill color surface in
the same task or create a tagged child task before completion.

The repository includes a rerunnable dry run for this exact scenario:

```bash
just tag-dependency-dry-run
```

## Common Initialization

Prompt:

```text
Create a new temporary GitHub-backed git repository using the documented
initialization sequence. Create main, push it, then run `but setup` before the
GitButler branch flows.
```

Commands:

```bash
git init -b main
git config user.name workflow-test
git config user.email workflow-test@example.invalid
gh repo create <owner>/<temp-repo> --private --source=. --remote=origin   --disable-issues --disable-wiki
printf '# Demo
' > README.md
mkdir -p src
printf 'base
' > src/app.txt
git add README.md src/app.txt
git commit -m "chore: initialize demo"
git push -u origin main
but setup
but status
```

`but setup` switches the checkout to GitButler's managed workspace branch and
sets the target branch to `origin/main`.

## Flow 1: Plain GitButler Branch PR

Prompt:

```text
In a fresh temporary GitHub-backed repo, demonstrate the plain GitButler branch
PR flow. Start from main, run `but setup`, make one GitButler branch, commit one
change with `but commit`, push the branch, open a PR, verify the PR head/base,
and delete the temporary repo.
```

Commands:

```bash
but branch new demo/plain-branch
printf 'plain branch change
' > plain.txt
but status
but commit demo/plain-branch -m "test: add plain branch change"
but push demo/plain-branch

# Preferred when GitButler forge auth is configured:
but pr new demo/plain-branch   -m $'test: plain branch flow

Live GitButler plain branch flow.'   --json

# Reliable fallback used in the live run when GitButler forge auth was absent:
gh pr create --repo <owner>/<repo>   --base main   --head demo/plain-branch   --title "test: plain branch flow"   --body "Live GitButler plain branch flow."

gh pr view demo/plain-branch --repo <owner>/<repo>   --json number,url,state,headRefName,baseRefName
```

The live run proved:

```json
{
  "baseRefName": "main",
  "headRefName": "demo/plain-branch",
  "state": "OPEN"
}
```

Use this for one coherent change that should become one PR.

## Flow 2: Multi-Commit GitButler Branch PR

Prompt:

```text
In a fresh temporary GitHub-backed repo, demonstrate a multi-commit GitButler
session branch. Start from main, run `but setup`, make two commits on one
GitButler branch, push the branch, open one PR, and verify the PR contains both
commits.
```

Commands:

```bash
but branch new demo/multi-commit
printf 'session edit one
' > session.txt
but commit demo/multi-commit -m "test: add first session edit"
printf 'session edit two
' >> session.txt
but commit demo/multi-commit -m "test: add second session edit"
but push demo/multi-commit
but pr new demo/multi-commit   -m $'test: multi-commit branch flow

Live GitButler multi-commit branch flow.'   --json
# or: gh pr create --base main --head demo/multi-commit ...

gh pr view demo/multi-commit --repo <owner>/<repo>   --json number,url,state,headRefName,baseRefName,commits
```

The live run proved that one GitButler branch can carry two commits and GitHub
shows both commits in one PR.

Use this when the review unit is one PR, but the local history should preserve
multiple meaningful commits.

## Flow 3: GitButler Stacked PRs For Multiple Meaty Slices

Prompt:

```text
In a fresh temporary GitHub-backed repo, demonstrate the GitButler stacked PR
flow. Start from main, run `but setup`, create a base GitButler branch, create a
child branch anchored on the base, commit one meaty slice to each branch, push
both branches, open two PRs with the child PR based on the base branch, and
verify GitHub has both open PRs with the expected bases.
```

Commands:

```bash
but branch new demo/stack-base
printf 'stack base
' > stack.txt
but commit demo/stack-base -m "test: add stack base"

but branch new --anchor demo/stack-base demo/stack-child
printf 'stack child
' >> stack.txt
but commit demo/stack-child -m "test: add stack child"
but status

but push demo/stack-base
but push demo/stack-child

but pr new demo/stack-base   -m $'test: stack base flow

Live GitButler stack base flow.'   --json
but pr new demo/stack-child   -m $'test: stack child flow

Live GitButler stack child flow.'   --json

# Fallback used when GitButler forge auth is absent:
gh pr create --repo <owner>/<repo>   --base main   --head demo/stack-base   --title "test: stack base flow"   --body "Live GitButler stack base flow."
gh pr create --repo <owner>/<repo>   --base demo/stack-base   --head demo/stack-child   --title "test: stack child flow"   --body "Live GitButler stack child flow."

gh pr list --repo <owner>/<repo> --state open   --json number,url,title,headRefName,baseRefName
```

The live run proved:

```text
demo/stack-base  -> main
demo/stack-child -> demo/stack-base
```

Use this for dependent meaty slices that should be reviewed separately. Commit
base-slice review fixes to the base branch, not automatically to the top branch.
GitButler stack curation is sequential agent work in one managed workspace.

## Flow 4: Parallel Physical Git Worktrees

Prompt:

```text
In a fresh temporary GitHub-backed repo, demonstrate parallel physical git
worktrees. Run `but setup` only to show the GitButler context, then leave the
GitButler workspace and create two physical git worktrees based on main. Make
one commit in each worktree, push one branch per worktree, open one PR per
branch, verify both PRs target main, then remove the worktrees and delete the
temp repo.
```

Commands:

```bash
# If the repo is in GitButler mode with no active branches, `but teardown` may
# fail with "No active branches found". A direct checkout of main cleanly leaves
# the GitButler workspace and removes GitButler hooks.
git checkout main

GEST_VCS_EXECUTION=git-worktrees git worktree add -b demo/worktree-a /tmp/demo-worktree-a main
GEST_VCS_EXECUTION=git-worktrees git worktree add -b demo/worktree-b /tmp/demo-worktree-b main

(
  cd /tmp/demo-worktree-a
  printf 'workspace a isolated change
' > workspace-a.txt
  git add workspace-a.txt
  git commit -m "test: add worktree a change"
  git push -u origin demo/worktree-a
  gh pr create --repo <owner>/<repo>     --base main     --head demo/worktree-a     --title "test: worktree a flow"     --body "Live physical worktree A flow."
)

(
  cd /tmp/demo-worktree-b
  printf 'workspace b isolated change
' > workspace-b.txt
  git add workspace-b.txt
  git commit -m "test: add worktree b change"
  git push -u origin demo/worktree-b
  gh pr create --repo <owner>/<repo>     --base main     --head demo/worktree-b     --title "test: worktree b flow"     --body "Live physical worktree B flow."
)

gh pr list --repo <owner>/<repo> --state open   --json number,url,title,headRefName,baseRefName

git worktree remove /tmp/demo-worktree-a
git worktree remove /tmp/demo-worktree-b
```

The live run proved that both worktree PRs target `main` independently:

```text
demo/worktree-a -> main
demo/worktree-b -> main
```

This is the right model for concurrent write agents. Do not use GitButler
parallel lanes as agent isolation.

## Cleanup Prompt

Prompt:

```text
After each live GitHub workflow example, verify the expected PR state, capture
the command log, and delete the temporary GitHub repository with
`gh repo delete <owner>/<repo> --yes`. Then verify the repo no longer exists.
```

Commands:

```bash
gh repo delete <owner>/<repo> --yes
gh repo view <owner>/<repo> --json name
```

The second command should fail after cleanup. If you need to debug a failed run,
set a keep-repos flag, inspect the repo, then delete it manually.
