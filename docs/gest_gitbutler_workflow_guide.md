# Gest, GitButler, And Worktree Workflow Guide

This guide is for a human who wants to reproduce the Gest/Codex workflow by
hand, understand why the branch policy exists, and practice the supported
branch modes in a disposable repository.

The short version:

- Gest tracks intent, task hierarchy, phase/dependency state, notes, and
  metadata.
- Git/GitButler tracks code history.
- Codex skills teach agents how to move between Gest, Git/GitButler, GitHub,
  tests, docs, review, and commits.
- GitButler stacks are excellent for sequential stack curation.
- Physical git worktrees are the safe default for true parallel write work.
- Do not use GitButler parallel lanes as the primitive for multiple write agents.

## Install The Skills

From this repository:

```bash
scripts/install.sh /path/to/target/repo
```

That copies:

```text
.agents/skills/g*
docs/*.md
tools/gest_mermaid_graph.py
AGENTS.template.md -> AGENTS.md, only when AGENTS.md does not already exist
```

After installation, edit `AGENTS.md` in the target repository. Replace the
placeholder project name, source directory, docs/spec paths, and verification
commands.

Initialize Gest if needed:

```bash
cd /path/to/target/repo
gest init --local
```

Inspect the project ledger before creating new work:

```bash
gest search "<project keyword>" --all --json
gest task list --all --json
gest iteration list --all --json
```

The lab later in this guide uses `/tmp`. It is intentionally disposable. Do not
run the cleanup commands against a real project directory.

## What The g Skills Do

Use `gtw` first for most real work. It is the router. It decides whether the
request is a quick session leaf, a durable development slice, a spec/planning
task, or an orchestrated iteration.

The full set:

| Skill | Purpose |
| --- | --- |
| `gtw` | Track work: classify, parent, tag, choose metadata, route next steps. |
| `gbs` | Brainstorm fuzzy ideas, compare approaches, decide whether to spec or plan. |
| `gsp` | Write/update a Gest spec artifact. |
| `gpl` | Plan tasks, phases, dependencies, and branch/execution metadata. |
| `gis` | Create/update durable Gest tasks and subissues. |
| `gpr` | Promote/sync durable work with GitHub issues. |
| `gim` | Implement one concrete Gest task end to end. |
| `gor` | Orchestrate a phased iteration, sequentially or through physical worktrees. |
| `gfm` | Format, lint, typecheck, compile/static checks, and diff hygiene. |
| `gte` | Run or add behavioral tests, smoke checks, and integration checks. |
| `gdo` | Audit and update docs. |
| `grv` | Review the changeset for bugs, regressions, safety, and missing tests. |
| `gpa` | Review/accept a GitHub PR with PR state, Gest context, and merge guidance. |
| `gcm` | Commit a verified checkpoint with an appropriate message. |

The skills are not shell commands. They are local instructions for Codex. You
can invoke them in chat as `/gtw`, `$gtw`, `gtw:`, or by naming a stage directly
such as `gcm: commit this verified slice`.

## Gest Setup Model

Gest has four important concepts in this workflow:

- **GitHub issue**: external human-visible durable intent.
- **Development iteration**: a Gest execution plan for larger or multi-session
  work.
- **Session iteration**: a Gest execution plan for current-session work.
- **Outline task**: durable task tree structure, linked with native
  `child-of` / `parent-of` relationships.

Preferred depth:

```text
depth 0: product area / GitHub-scale initiative
depth 1: coherent feature, subsystem, or workstream
depth 2: concrete implementable task
depth 3: tiny tactical subtask, only when useful
```

Tags are filters. Links are hierarchy. Use task metadata for machine-readable
facts and task notes for prose summaries.

Useful task note shape:

```text
Done: what changed
Verification: commands/checks run
Follow-up: only real residual issues
```

Command pattern:

```bash
gest task note add <task-id> --agent codex --body "Done: ...\nVerification: ..."
gest task complete <task-id> --quiet
```

## Manual Gest Lifecycle

The skills automate this, but it is useful to know the manual shape.

Create an iteration for the current session or development slice:

```bash
iteration_id=$(
  gest iteration create "Document workflow guide" \
    --description "Write user-facing docs for the Gest/GitButler workflow." \
    --tag workflow \
    --quiet
)
```

Create a durable parent task:

```bash
parent_id=$(
  gest task create "Document reproducible workflows" \
    -d "Create user-facing workflow documentation and a reproducible lab." \
    -i "$iteration_id" \
    --phase 1 \
    --tag workflow \
    --tag docs \
    --tag parent \
    --metadata workflow.kind=development \
    --metadata depth=1 \
    --quiet
)
```

Create and claim a concrete leaf:

```bash
leaf_id=$(
  gest task create "Write workflow guide" \
    -d "Add setup, skill, branch, stack, and worktree docs." \
    -i "$iteration_id" \
    --phase 1 \
    -l child-of:"$parent_id" \
    --tag workflow \
    --tag docs \
    --tag leaf \
    --metadata workflow.kind=development \
    --metadata depth=2 \
    --metadata vcs.tool=git \
    --metadata vcs.branch_mode=development-branch \
    --metadata vcs.execution=main-worktree \
    --metadata vcs.parallel_allowed=false \
    --quiet
)

gest task claim --as codex "$leaf_id" --quiet
```

Add or inspect metadata later:

```bash
gest task meta set "$leaf_id" vcs.branch gest/demo-workflow-guide --quiet
gest task meta get "$leaf_id" vcs --json
```

Complete the leaf after review and verification:

```bash
gest task note add "$leaf_id" --agent codex --body "Done: ...\nVerification: ..."
gest task complete "$leaf_id" --quiet
gest iteration status "$iteration_id" --json
```

Generate checkpoint graphs if the project installed `gest_mermaid_graph.py`:

```bash
python3 tools/gest_mermaid_graph.py \
  --project-root "$PWD" \
  --all \
  --output exports/gest/relationships.html

python3 tools/gest_mermaid_graph.py \
  --project-root "$PWD" \
  --iteration "$iteration_id" \
  --output exports/gest/relationships-focused.html
```

## Branch Model Vs Execution Model

Keep two decisions separate:

- **Branch model**: how this work will be reviewed and integrated.
- **Execution model**: where agents are allowed to write files.

Branch names should be keyed to the highest meaningful Gest task for the current
workstream:

```text
gest/<task-id-short>-two-word-summary
session/<task-id-short>-two-word-summary
```

Use these branch modes:

| Mode | Use When |
| --- | --- |
| `session-branch` | Small tactical session work, or several small related edits. |
| `development-branch` | One coherent durable feature, fix, or workflow change. |
| `stacked-session` | Multiple meaty dependent session slices that should stay reviewable. |
| `stacked-development` | Multiple meaty dependent development slices, usually stacked PRs. |
| `parallel-worktrees` | Multiple independent meaty slices worked at the same time. |

Use these execution modes:

| Mode | Meaning |
| --- | --- |
| `main-worktree` | One agent writes in the current checkout. |
| `git-worktrees` | One physical git worktree per parallel task. |
| `gitbutler-workspace` | One sequential agent writes in the GitButler-managed workspace. |
| `jj-workspaces` | One jj workspace per parallel task, if using jj. |

Record the decision in Gest metadata when the work is more than tiny:

```text
vcs.tool=git|git-butler|jj
vcs.base_branch=main
vcs.base_sha=<sha>
vcs.branch_mode=session-branch|development-branch|stacked-session|stacked-development|parallel-worktrees
vcs.execution=main-worktree|git-worktrees|gitbutler-workspace|jj-workspaces
vcs.parallel_allowed=true|false
vcs.branch=<branch-name>
vcs.stack_root=<branch-name>
vcs.stack_parent=<branch-name>
vcs.stack_index=<n>
vcs.workspace_path=<absolute-path>
vcs.integration=fast-forward|squash|rebase|merge|stacked-pr|local-only
vcs.write_scope=<paths-or-subsystems>
```

## Why GitButler Is Sequential For Agents

GitButler parallel branches and stacked branches are built on one managed
workspace. That is powerful for a human curating hunks and commits, but it means
multiple agents writing concurrently can step on the same unassigned change set
or commit to the wrong lane.

Policy:

```text
GitButler stacks: yes, sequentially.
GitButler parallel lanes for concurrent agents: no.
Physical git worktrees for concurrent agents: yes.
```

Inside GitButler mode, use current `but` CLI write commands:

```bash
but status
but diff
but branch new <branch-name>
but branch new -a <anchor-branch> <child-branch>
but stage <file-or-hunk-id> <branch-name>
but commit -m "<message>" <branch-name>
but commit -o -m "<message>" <branch-name>
but push <branch-name>
but pr
```

Do not use these while GitButler owns the workspace:

```bash
git commit
git switch
git checkout
git branch <write operation>
```

Read-only git commands such as `git log` or `git diff` are fine when they help
you inspect history, but prefer `but status` and `but diff` for branch ownership.

## Integration Defaults

For simple branches:

```text
rebase onto main, then fast-forward or squash
```

For GitButler stacks:

```text
review/merge bottom-up
```

GitHub merge commits are acceptable for GitButler-managed stacked PRs because
they make stack retargeting smoother. For simple non-stack branches, keep the
history linear when possible.

For physical worktrees:

```text
finish each worktree, rebase if needed, integrate intentionally, then clean up
```

## Reproduce The Workflow Lab

This lab creates a disposable repository, bootstraps a small TypeScript command
contract, and then exercises the supported branch/worktree modes. It
intentionally avoids concurrent GitButler parallel lanes. For the full
setup-only version of the TypeScript project, see
[`gsu_typescript_hello_world.md`](gsu_typescript_hello_world.md).

Set paths:

```bash
skills_repo=/path/to/codex_gest_git_skills
lab=/tmp/gest-gitbutler-workflow-lab
rm -rf "$lab" "$lab-wt-a" "$lab-wt-b"
mkdir -p "$lab/src"
cd "$lab"
```

Initialize git:

```bash
git init -b main
git config user.name "workflow-test"
git config user.email "workflow-test@example.invalid"
printf '# Workflow Lab\n' > README.md
cat > package.json <<'JSON'
{
  "name": "gest-gitbutler-workflow-lab",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "devDependencies": {
    "@biomejs/biome": "^2.4.14",
    "@types/node": "^25.0.0",
    "typescript": "^5.9.3"
  }
}
JSON
cat > tsconfig.json <<'JSON'
{
  "compilerOptions": {
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "target": "ES2022"
  },
  "include": ["src/**/*.ts"]
}
JSON
cat > src/index.ts <<'TS'
export function greet(name = "world"): string {
  return `Hello, ${name}!`;
}

console.log(greet());
TS
cat > .gitignore <<'GITIGNORE'
node_modules/
dist/
.local/
.DS_Store
GITIGNORE
git add README.md package.json tsconfig.json src/index.ts .gitignore
git commit -m "chore: initialize workflow lab"
```

Install the skills:

```bash
"$skills_repo/scripts/install.sh" "$lab"
cat > Justfile <<'JUST'
export npm_config_cache := ".local/npm-cache"

setup:
  npm install

lint path="src package.json tsconfig.json":
  npm exec -- biome check {{path}}

typecheck:
  npm exec -- tsc --noEmit

build:
  npm exec -- tsc

smoke:
  npm exec -- tsc
  node dist/index.js

verify:
  just lint
  just typecheck
  just build
  just smoke
  git diff --check
JUST
cat >> AGENTS.md <<'MD'

## Lab Command Contract

Use the `Justfile` as the stable command interface:

```bash
just setup
just lint [path]
just typecheck
just build
just smoke
just verify
git diff --check
```

Mappings:

- Setup: `just setup`, which runs `npm install` with `.local/npm-cache`.
- Lint: `just lint [path]`, which runs Biome check.
- Typecheck: `just typecheck`, which runs `tsc --noEmit`.
- Build: `just build`, which runs `tsc`.
- Smoke: `just smoke`, which compiles then runs the hello-world program.
- Full verification: `just verify`.
MD
git add .agents AGENTS.md docs tools Justfile
git commit -m "chore: install gest codex skills and command contract"
just setup
just verify
```

### Flow 1: GitButler Plain Branch

Enter GitButler mode:

```bash
but setup
but status
```

Create one branch and commit one change:

```bash
but branch new gest-demo-plain-branch
printf 'plain branch change\n' >> app.txt
but status
but commit -m "test: exercise plain branch" gest-demo-plain-branch
```

Expected result: `but status` shows a branch named `gest-demo-plain-branch`
with one commit.

### Flow 2: Multi-Commit Session Branch

Create one session branch and make two small related commits:

```bash
but branch new session-demo-small-edits
printf 'first session edit\n' > session.txt
but commit -m "test: add first session edit" session-demo-small-edits
printf 'second session edit\n' >> session.txt
but commit -m "test: add second session edit" session-demo-small-edits
```

Expected result: one branch with two commits. This is the right shape when a
session contains several small related edits under one Gest parent.

Unapply finished lanes before stack practice, so the next exercise stays clean:

```bash
but unapply gest-demo-plain-branch
but unapply session-demo-small-edits
```

### Flow 3: GitButler Stacked Branches

Create a base branch and commit the first meaty slice:

```bash
but branch new gest-demo-stack-base
printf 'base stack slice\n' > stack.txt
but commit -m "test: add stack base slice" gest-demo-stack-base
```

Create a child branch anchored on the base:

```bash
but branch new -a gest-demo-stack-base gest-demo-stack-child
printf 'child stack slice\n' >> stack.txt
but commit -m "test: add stack child slice" gest-demo-stack-child
but status
```

Expected result: `but status` shows `gest-demo-stack-child` stacked above
`gest-demo-stack-base`. This is the right shape for dependent meaty slices that
should be reviewed separately.

Important habit: always commit fixes to the branch where they belong. Review
feedback for the base slice should go to the base branch, not automatically to
the top branch.

Leave GitButler mode before physical worktree practice:

```bash
but teardown
git checkout main
```

`but teardown` may check out an active GitButler branch first. Explicitly return
to `main` before the worktree flow.

### Flow 4: Physical Git Worktrees

Create two separate worktrees from `main`:

```bash
git worktree add -b gest-demo-worktree-a "$lab-wt-a" main
git worktree add -b gest-demo-worktree-b "$lab-wt-b" main
```

Make an isolated commit in worktree A:

```bash
cd "$lab-wt-a"
printf 'worktree a isolated change\n' > worktree-a.txt
git add worktree-a.txt
git commit -m "test: add worktree a change"
```

Make an isolated commit in worktree B:

```bash
cd "$lab-wt-b"
printf 'worktree b isolated change\n' > worktree-b.txt
git add worktree-b.txt
git commit -m "test: add worktree b change"
```

Integrate intentionally in the main checkout:

```bash
cd "$lab"
git merge --ff-only gest-demo-worktree-a
cd "$lab-wt-b"
git rebase main
cd "$lab"
git merge --ff-only gest-demo-worktree-b
```

Clean up:

```bash
git worktree remove "$lab-wt-a"
git worktree remove "$lab-wt-b"
git worktree list
git status --short --branch
```

Expected result: only the main worktree remains, and `main` contains both
worktree commits.

## Review The Lab History

Inspect all branches:

```bash
git log --oneline --decorate --all --graph -20
```

You should see:

- one plain GitButler branch
- one multi-commit session branch
- one stacked base/child pair
- two physical worktree branches integrated into `main`

Run diff hygiene:

```bash
git diff --check
```

## How This Maps Back To Gest

A small session branch might use metadata like:

```text
workflow.kind=session
vcs.tool=git-butler
vcs.branch_mode=session-branch
vcs.execution=gitbutler-workspace
vcs.parallel_allowed=false
vcs.branch=session/<task-id>-small-edits
```

A stacked development slice:

```text
workflow.kind=development
vcs.tool=git-butler
vcs.branch_mode=stacked-development
vcs.execution=gitbutler-workspace
vcs.parallel_allowed=false
vcs.stack_root=gest/<task-id>-stack-base
```

A parallel physical worktree phase:

```text
workflow.kind=development
vcs.tool=git
vcs.branch_mode=parallel-worktrees
vcs.execution=git-worktrees
vcs.parallel_allowed=true
vcs.workspace_path=/absolute/path/to/worktree
```

The Gest rule is not "never parallel." The rule is:

```text
never multiple write agents in one GitButler workspace
```

Parallel work is fine when each writable task has its own physical checkout.

## Common Mistakes

Mistake: using `git commit` in GitButler mode.

Fix: use `but commit`, with an explicit branch target when more than one branch
is applied.

Mistake: treating GitButler parallel lanes as agent isolation.

Fix: use physical git worktrees for concurrent write agents.

Mistake: creating a branch from the permanent product root task.

Fix: key branch names to the highest meaningful current workstream task, not a
forever parent.

Mistake: leaving a branch silently ahead of upstream after a checkpoint.

Fix: after every Codex-created commit, run `git status --short --branch`, push
if there is an upstream and the work is not intentionally local-only, or record
the explicit no-push reason.

Mistake: pushing a branch and treating the push as the end of review.

Fix: after pushing a non-mainline branch, create or update its pull request, run
`gpa`, report the PR review findings/state to the user, and ask whether to merge.
Only merge immediately when the user explicitly asked for that merge in the
current turn.

Mistake: completing Gest leaves without a note.

Fix: add `Done` and `Verification` notes before completing non-trivial leaves.

## What To Ask Codex

Good prompts:

```text
/gtw create a session branch and make these two small docs edits
```

```text
/gtw plan this feature as stacked development branches because the API refactor
and UI work should be reviewed separately
```

```text
/gtw run this iteration with physical worktrees; the two tasks touch disjoint
files and can be integrated afterward
```

```text
gcm: commit this verified checkpoint and push if the branch has an upstream
```

```text
gpa: review PR #12, add missing Gest context to the body, and recommend whether
to merge
```

When in doubt, ask Codex to explain the proposed branch model and execution
model before it edits files.

After a pushed non-mainline branch, Codex should not wait for the user to notice
the branch on GitHub. It should create or update the PR, run `gpa`, report the
review packet, and ask whether to merge unless the user already asked for that
merge in the current turn.

## PR Acceptance With Gest Context

Use `gpa` when a branch has become a GitHub pull request. A PR is the
GitHub-facing checkpoint of a Gest-tracked workstream, so it should carry enough
Gest context for a human to review it without reconstructing the chat.

`gpa` should gather:

- PR title, body, branch, base, mergeability, checks, commits, and files
- PR diff
- review state
- related Gest parent tasks, leaves, artifacts/specs, iterations, notes, and
  metadata
- graph links generated at checkpoints

The PR review packet should include:

```markdown
## Gest Context

- Parent: `<id>` <title>
- Leaves:
  - `<id>` <title>
- Iteration: `<id>` <title>
- Artifacts/specs: <none or list>
- Verification: <commands/checks>
- Follow-ups: <none or list>
- Graphs:
  - overall: <path-or-url>
  - focused: <path-or-url>
```

If the PR body lacks this appendix, ask Codex to update it with `gh pr edit`.
For public repos, keep the PR body sanitized and store private details in Gest
notes instead.
