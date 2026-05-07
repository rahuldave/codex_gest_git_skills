# Git And GitButler Tutorial

This tutorial creates four temporary GitHub repositories with fixed names,
runs four agent workflows, and tells you exactly what to check after each turn.

You will learn:

1. ordinary git branch PR
2. ordinary git multi-commit PR
3. GitButler stacked PRs for dependent slices
4. physical git worktrees for independent parallel slices
5. tag classification and ast-grep dependency checks before code edits

Only step 3 uses GitButler as the main tool.

## Latest Live Run

This tutorial was rerun against live temporary GitHub repositories on
2026-05-07. The historical transcript is
`docs/live_gitbutler_tutorial_transcript_2026-05-07.md`.

Observed results:

- Step 1 used ordinary git and opened `tutorial/plain` into `main`.
- Step 2 used ordinary git and opened a two-commit `tutorial/multi` PR into
  `main`.
- Step 3 used GitButler for the local stack. With forge auth configured,
  `but pr new tutorial/stack-base -m ... --json` created the base PR. The child
  command `but pr new tutorial/stack-child --default --json` returned GitHub
  `422 Unprocessable Entity`, so the agent used `gh pr create --base
  tutorial/stack-base --head tutorial/stack-child` for the child PR.
- Step 4 used physical git worktrees and opened two independent PRs into
  `main`.
- Cleanup deleted all four temporary GitHub repositories with
  `gh repo delete --yes`.

## What This Tutorial Will Do

The agent will create and later delete these GitHub repositories under your
GitHub account:

```text
agent-gest-git-tutorial-plain
agent-gest-git-tutorial-multi
agent-gest-git-tutorial-stack
agent-gest-git-tutorial-worktrees
```

Do not use those names for anything valuable. The prompts below tell the agent
to delete any existing repositories with those names before starting, then
delete them again during cleanup. Cleanup uses `gh repo delete --yes`.

Prerequisites:

- `gh auth status -h github.com` succeeds.
- Your GitHub auth has `repo` and `delete_repo` scopes.
- `git`, `gh`, `gest`, `just`, and `but` are installed.
- You are comfortable letting the agent create and delete the four temporary
  repositories named above.

## Step 0: Setup And Cleanup Contract

What this step teaches:

The agent should use fixed repo names, clean up before and after the tutorial,
and tell you where it wrote logs.

Ask the agent:

```text
Run the Git/GitButler tutorial setup.

Use my GitHub account from `gh api user -q .login`.
Use exactly these temporary private repo names:

- agent-gest-git-tutorial-plain
- agent-gest-git-tutorial-multi
- agent-gest-git-tutorial-stack
- agent-gest-git-tutorial-worktrees

Before starting, delete any existing GitHub repos with those names using
`gh repo delete <owner>/<name> --yes`, ignoring "not found" errors.

Create a local tutorial root at `/tmp/agent-gest-git-tutorial`.
Create `/tmp/agent-gest-git-tutorial/logs`.

For each following step, write a command log in that logs directory. After all
steps finish, delete the four GitHub repos unless I explicitly ask to keep them.
```

After the agent finishes, check:

```bash
test -d /tmp/agent-gest-git-tutorial/logs
```

The agent should report your GitHub owner and the exact log directory.

## Step 1: Ordinary Git Branch PR

What this step teaches:

Use ordinary git for one simple review branch. GitButler is not needed.

Repository:

```text
agent-gest-git-tutorial-plain
```

Ask the agent:

```text
Run tutorial step 1: ordinary git branch PR.

Create private GitHub repo `agent-gest-git-tutorial-plain`.
Clone or initialize it under `/tmp/agent-gest-git-tutorial/plain`.
Create `main` with README.md containing `plain tutorial base`.
Push `main`.

Create branch `tutorial/plain` with ordinary git, not GitButler.
Add `plain.txt` containing `plain branch change`.
Commit with message `test: add plain branch change`.
Push the branch.
Open a PR with:
- base: `main`
- head: `tutorial/plain`
- title: `test: plain git branch flow`

Write all commands and key outputs to
`/tmp/agent-gest-git-tutorial/logs/01-plain-git-branch.log`.
```

After the agent finishes, check:

```bash
gh pr view tutorial/plain \
  --repo "$(gh api user -q .login)/agent-gest-git-tutorial-plain" \
  --json state,baseRefName,headRefName,title
```

Expected:

```text
state: OPEN
baseRefName: main
headRefName: tutorial/plain
title: test: plain git branch flow
```

Commands it should have used:

- `git checkout -b tutorial/plain` or equivalent ordinary git branch creation
- `git commit`
- `git push`
- `gh pr create`

Commands it should not have used:

- `but setup`
- `but branch new`
- `but commit`

## Step 2: Ordinary Git Multi-Commit PR

What this step teaches:

Use ordinary git when one review branch needs more than one commit.
GitButler is still not needed.

Repository:

```text
agent-gest-git-tutorial-multi
```

Ask the agent:

```text
Run tutorial step 2: ordinary git multi-commit PR.

Create private GitHub repo `agent-gest-git-tutorial-multi`.
Clone or initialize it under `/tmp/agent-gest-git-tutorial/multi`.
Create `main` with README.md containing `multi tutorial base`.
Push `main`.

Create branch `tutorial/multi` with ordinary git, not GitButler.
Add `session.txt` containing `session edit one`.
Commit with message `test: add first session edit`.
Append `session edit two` to `session.txt`.
Commit with message `test: add second session edit`.
Push the branch.
Open a PR with:
- base: `main`
- head: `tutorial/multi`
- title: `test: multi commit git branch flow`

Write all commands and key outputs to
`/tmp/agent-gest-git-tutorial/logs/02-multi-commit-git-branch.log`.
```

After the agent finishes, check:

```bash
owner="$(gh api user -q .login)"
gh pr view tutorial/multi \
  --repo "$owner/agent-gest-git-tutorial-multi" \
  --json state,baseRefName,headRefName,title,commits
```

Expected:

```text
state: OPEN
baseRefName: main
headRefName: tutorial/multi
title: test: multi commit git branch flow
commits: two commits on the PR branch
```

Commands it should not have used:

- `but setup`
- `but branch new`
- `but commit`

## Step 3: GitButler Stacked PRs

What this step teaches:

Use GitButler when you have multiple dependent, meaty slices that should be
reviewed separately. This is the GitButler step.

Repository:

```text
agent-gest-git-tutorial-stack
```

Ask the agent:

```text
Run tutorial step 3: GitButler stacked PRs.

Create private GitHub repo `agent-gest-git-tutorial-stack`.
Clone or initialize it under `/tmp/agent-gest-git-tutorial/stack`.
Create `main` with README.md containing `stack tutorial base`.
Push `main`.

Run `but setup`.
Create GitButler branch `tutorial/stack-base`.
Add `stack.txt` containing `stack base`.
Commit to `tutorial/stack-base` with message `test: add stack base`.

Create GitButler branch `tutorial/stack-child` anchored on
`tutorial/stack-base`.
Append `stack child` to `stack.txt`.
Commit to `tutorial/stack-child` with message `test: add stack child`.

Push both branches.
Open two PRs:
- `tutorial/stack-base` into `main`, title `test: stack base flow`
- `tutorial/stack-child` into `tutorial/stack-base`, title `test: stack child flow`

Prefer `but pr new` after `but push` when GitButler forge auth is configured.
If the child stack PR fails non-interactively, use `gh pr create` with
`--base tutorial/stack-base --head tutorial/stack-child` and record the exact
GitButler error in the log. On the 2026-05-07 live run, the base PR was created
by `but pr new`, while the child PR required this `gh pr create` fallback after
GitButler returned GitHub `422 Unprocessable Entity`.

Write all commands and key outputs to
`/tmp/agent-gest-git-tutorial/logs/03-gitbutler-stack.log`.
```

After the agent finishes, check:

```bash
owner="$(gh api user -q .login)"
gh pr list \
  --repo "$owner/agent-gest-git-tutorial-stack" \
  --state open \
  --json title,baseRefName,headRefName
```

Expected:

```text
PR: test: stack base flow
baseRefName: main
headRefName: tutorial/stack-base

PR: test: stack child flow
baseRefName: tutorial/stack-base
headRefName: tutorial/stack-child
```

Commands it should have used:

- `but setup`
- `but branch new tutorial/stack-base`
- `but branch new --anchor tutorial/stack-base tutorial/stack-child`
- `but commit`
- `but push`

This step should not use physical git worktrees.

## Step 4: Physical Git Worktrees

What this step teaches:

Use physical git worktrees for independent parallel slices. Do not use
GitButler parallel lanes as an agent parallelism primitive.

Repository:

```text
agent-gest-git-tutorial-worktrees
```

Ask the agent:

```text
Run tutorial step 4: physical git worktrees.

Create private GitHub repo `agent-gest-git-tutorial-worktrees`.
Clone or initialize it under `/tmp/agent-gest-git-tutorial/worktrees`.
Create `main` with README.md containing `worktree tutorial base`.
Push `main`.

Create two physical git worktrees:
- `/tmp/agent-gest-git-tutorial/worktree-a` on branch `tutorial/worktree-a`
- `/tmp/agent-gest-git-tutorial/worktree-b` on branch `tutorial/worktree-b`

Prefix the raw worktree creation commands with
`GEST_VCS_EXECUTION=git-worktrees`.

In worktree A, add `worktree-a.txt` containing `worktree a isolated change`,
commit with message `test: add worktree a change`, push the branch, and open a
PR into `main` titled `test: worktree a flow`.

In worktree B, add `worktree-b.txt` containing `worktree b isolated change`,
commit with message `test: add worktree b change`, push the branch, and open a
PR into `main` titled `test: worktree b flow`.

Remove both physical worktrees after the PRs are open.

Write all commands and key outputs to
`/tmp/agent-gest-git-tutorial/logs/04-physical-worktrees.log`.
```

After the agent finishes, check:

```bash
owner="$(gh api user -q .login)"
gh pr list \
  --repo "$owner/agent-gest-git-tutorial-worktrees" \
  --state open \
  --json title,baseRefName,headRefName
```

Expected:

```text
PR: test: worktree a flow
baseRefName: main
headRefName: tutorial/worktree-a

PR: test: worktree b flow
baseRefName: main
headRefName: tutorial/worktree-b
```

Commands it should have used:

- `GEST_VCS_EXECUTION=git-worktrees git worktree add ...`
- ordinary `git commit` inside each physical worktree
- `gh pr create`

Commands it should not have used:

- GitButler parallel lanes
- two write agents in one GitButler workspace

## Step 5: Tags And ast-grep Dependency Check

What this step teaches:

Before the agent edits code, it should classify the task with project tags and
run ast-grep against the semantic contract that is changing. If another surface
depends on that contract, the agent should expand the task or create a tagged
child task before implementation.

Local fixture:

```text
/tmp/agent-gest-git-tutorial/tag-ast-grep
```

Ask the agent:

```text
Run tutorial step 5: tag classification and ast-grep dependency check.

Create `/tmp/agent-gest-git-tutorial/tag-ast-grep/src`.

Create `src/colors.js` containing a function named
`countOrProbabilityColorScale`.
Create `src/histogram.js` that calls `countOrProbabilityColorScale`.
Create `src/pill.js` that calls `countOrProbabilityColorScale`.

Before editing anything, classify the requested change "change histogram colors
for low-count bins" with these tags:
- selected existing tag: `count-or-probability-coloring`
- selected existing tag: `histogram-colors`
- selected existing tag: `probability-pill-colors`
- rejected near miss: `reader-ui`

Then run:

`ast-grep run --lang javascript --pattern 'countOrProbabilityColorScale($$$)' --json=compact src`

The dependency impact should find both:
- `src/histogram.js`
- `src/pill.js`

Do not change the fixture in this step. Write the selected tags, rejected tag,
ast-grep command, and dependency-impact conclusion to
`/tmp/agent-gest-git-tutorial/logs/05-tag-ast-grep.log`.
```

After the agent finishes, check:

```bash
rg "count-or-probability-coloring|histogram.js|pill.js|reader-ui" \
  /tmp/agent-gest-git-tutorial/logs/05-tag-ast-grep.log
```

Expected:

```text
count-or-probability-coloring
histogram.js
pill.js
reader-ui
```

The agent should report that a histogram-color implementation must also account
for the probability-pill color surface, or create a child task tagged with the
same semantic dependency before completion.

## Step 6: Cleanup

Ask the agent:

```text
Run tutorial cleanup.

Delete these GitHub repositories if they exist:
- agent-gest-git-tutorial-plain
- agent-gest-git-tutorial-multi
- agent-gest-git-tutorial-stack
- agent-gest-git-tutorial-worktrees

Use `gh repo delete <owner>/<repo> --yes`.
Remove `/tmp/agent-gest-git-tutorial/worktree-a` and
`/tmp/agent-gest-git-tutorial/worktree-b` if they still exist.
Keep `/tmp/agent-gest-git-tutorial/logs` unless I ask you to remove logs.
```

After cleanup, check one repo:

```bash
owner="$(gh api user -q .login)"
gh repo view "$owner/agent-gest-git-tutorial-plain"
```

Expected:

```text
repository not found
```

## Automated Regression Labs

The scripts in this repo are regression checks, not the beginner tutorial:

```bash
just workflow-lab
just integration-live
```

They intentionally stress GitButler itself. Read this tutorial first; use those
scripts when you want to verify the reusable skill repository.
