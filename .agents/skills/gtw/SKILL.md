---
name: gtw
description: Gest Track Work. Use for substantial coding, debugging, implementation, refactoring, documentation, verification, GitHub issue planning, or project work. GTW is the router that classifies requests, chooses/creates Gest outline parents, creates session or development tasks, decides whether a spec or parallel work is needed, and routes to the g* stage skills.
---

# GTW: Gest Track Work

GTW is the default entry point for Gest-tracked work in this repository.

Read `docs/gest_codex_workflow.md` when more detail is needed. Keep
project-specific workflow notes in this repository or in user-level Codex
configuration.

## Core Job

Use GTW before any code-writing turn in a Gest-managed workspace. If a request
may edit code, templates, styles, tests, docs, workflow files, generated project
artifacts, or other repo files, first make the Gest tracking decision visible:
inspect or create the relevant task, claim it when needed, and record scope
changes before editing. Treat a user typo such as "gtx" as "gtw" unless a
separate named skill is actually available.

Before editing files, decide:

1. Is this a tiny untracked answer, a session task, or development work?
2. Does it need a spec before implementation?
3. Which durable outline task should parent this work?
4. Which tags and metadata apply?
5. Are there independent tasks that should run in parallel worktrees?
6. Is GitHub promotion appropriate?
7. Which stage skill should handle the next step?
8. Is the work reaching a commit checkpoint, or should it stay uncommitted for
   now?

Everything substantial should become a Gest task/issue with appropriate
dependencies.

For multi-stage substantial work, create a small GTW-owned treelet: one parent
task for the user request, with child leaves for separately verifiable stages
such as `gsp`, `gpl`, `gim`, `gfm`, `gte`, `gdo`, `grv`, `gpr`, and `gcm`.
Small tactical work may combine mechanical stages in one leaf, but the
completion note must still say which verification/review/promotion stages ran
or were intentionally skipped.

## Inspect First

Serialize Gest commands. In this workspace, local `.gest/` sync can make
read-looking commands write to SQLite.

Codex sandbox note: Gest's canonical database lives at
`~/Library/Application Support/gest/gest.db`, outside the workspace writable
roots. Run Gest mutations with `require_escalated`. If a read-looking command
emits `attempt to write a readonly database` or a sync-import readonly warning,
retry it with `require_escalated`. Use a narrow approval prefix such as
`["gest"]`.

```bash
gest search "<short phrase>" --all --json
gest task list --all --json
gest iteration list --all --json
```

If Gest is unavailable in the current directory, run from the repository root or
initialize the project with `gest init --local`.

## Gest Memory Lookup

Treat Gest as the durable project memory for substantial work. Before planning
or editing, run targeted searches for prior context and inspect the most
relevant hits.

Start narrow:

```bash
gest search "<feature or symptom>" --all --json --limit 20
gest search "<module/script/book name>" --all --json --limit 20
gest search "browser audit <topic>" --all --json --limit 20
gest search "Follow-up <topic>" --all --json --limit 20
```

Then inspect promising entities:

```bash
gest task show <id-or-prefix> --json
gest task note list <id-or-prefix> --json
gest iteration show <id-or-prefix> --json
gest iteration graph <id-or-prefix> --raw
```

Look especially for completion notes with `Done` / `Verification` /
`Follow-up`, browser-agent audit notes, unresolved follow-ups, GitHub metadata,
prior design decisions, rejected approaches, related iterations, and parent task
trees. Do not bulk-load the whole database unless targeted search fails or the
user asks for an audit.

## Classification

Choose one:

- `session leaf only`: small tactical work.
- `session leaf under outline`: small work under an existing durable parent.
- `new outline plus session leaves`: new durable area but not GitHub-scale.
- `development iteration`: larger, multi-session, spec-worthy, GitHub-worthy, or
  phased work.

Promote session-shaped work to development when it needs a spec/design decision,
spans sessions, should be visible on GitHub, has durable acceptance criteria,
creates a reusable product area, or requires staged delivery.

## Parenting

Use native Gest `child-of` links for hierarchy. Tags are filters, not hierarchy.

Preferred depth:

- depth 0: product area / GitHub-scale initiative
- depth 1: coherent feature or subsystem
- depth 2: concrete implementable task
- depth 3: tiny tactical subtask when useful

Long-lived outline parents may remain open across sessions. Do not complete a
parent just because a session leaf is complete.

## Tags And Metadata

Use tags such as `session`, `development`, `outline`, `issue`, `subissue`,
`parent`, `leaf`, `github`, area tags, and work-type tags.

Use metadata for source-of-truth facts:

```text
workflow.kind=session|development
depth=<0-3>
github.issue=<number>
github.url=<url>
outline.root=<gest-task-id>
parent_task=<gest-task-id>
```

## Creating Work

Create or reuse an active session/development iteration. Assign phases
deliberately; do not hardcode everything to phase 1.

Create concrete leaves before edits:

```bash
gest task create "<Leaf title>" \
  -d "<Concrete verifiable work>" \
  -i <iteration-id> \
  --phase <phase-number> \
  -l child-of:<parent-id> \
  --tag session \
  --tag leaf \
  --metadata workflow.kind=session \
  --metadata depth=2 \
  --quiet

gest task claim --as codex <leaf-id> --quiet
```

## Stage Routing

- `gbs`: explore rough ideas.
- `gsp`: create/update a spec artifact.
- `gpl`: decompose a spec/outline into tasks, phases, and iterations.
- `gis`: create/update durable Gest outline tasks.
- `gpr`: promote/sync durable work with GitHub issues.
- `gim`: implement one concrete task.
- `gor`: execute a phased iteration, sequentially or in parallel.
- `grv`: review current changes.
- `gfm`: format/lint/typecheck/static checks.
- `gte`: run unit, regression, smoke, and integration tests.
- `gdo`: update and verify docs.
- `gcm`: commit.

## Commit Cadence

Committing is not a Gest task by itself. Do not create tasks whose only purpose
is a normal Git commit.

Session work does not auto-commit every small leaf. Commit when the user asks,
when there is a coherent checkpoint, or when a long-lived parent/subtree reaches
a stable point.

Session classification alone is not a reason to skip `gcm`. A verified slice is
a commit-required checkpoint when it changes deployment/runtime configuration,
persistence, migrations, schemas, public APIs, user-visible UI, reusable
workflow material, publishable docs/templates, or a non-trivial multi-file
changeset. After verification and review, run `git status --short --branch`
before final response. If it shows Codex-owned changes and a commit-required
trigger applies, route through `gcm` before completing the handoff. If `gcm` is
intentionally skipped despite a dirty worktree, record the concrete no-commit
reason in the Gest note and final response.

Development work should be committed at verified durable checkpoints: after a
depth-1 workstream or coherent depth-2 subtree, before switching product areas,
before handoff, after risky bug/migration work, or before GitHub issue/PR sync.
Use `gcm`, stage explicit files, and never put Gest IDs in commit messages.
When Codex creates a commit, make a separate push/sync decision: verify
`git status --short --branch`, push if an upstream exists and local-only work
was not requested, or record the exact no-push reason. GitHub issue promotion
and `git push` are different decisions.

For development-mode implementation, make the commit judgment yourself after
each verified coherent depth-2 leaf or tightly related set of leaves. Prefer a
commit before claiming the next implementation slice when the completed work
changes schema, persistence, query semantics, public APIs, user-visible UI, or
non-trivial verification. Use the completed Gest notes to write detailed commit
bodies: `Done`, `Verification`, and real `Follow-up` details should become the
source material. The goal is useful bisect granularity, not one giant feature
commit.

## Checkpoint Hygiene

At every durable checkpoint, run the cleanup that future agents need:

- regenerate the overall Gest graph and a focused graph for the latest relevant
  iteration
- treat graph generation as a Gest database operation and do not run it in
  parallel with `gest`
- for every development depth-1 parent and development iteration, run the
  explicit `gpr` decision: create/sync the GitHub issue and record
  `github.issue`/`github.url`, or record why it was not promoted
- verify push state for each Codex-created commit; do not finish a checkpoint
  with an unmentioned `ahead` branch
- run `grv` after every code change before task completion, even for quick
  development without a pull request
- report graph paths, commit hashes, push status, review status, and GitHub
  issue decision

## Template Sync

When changing reusable workflow material, copy the reusable parts to
the version-controlled workflow template repository, then check, commit, and
push that repo. This applies to `g*` skills, AGENTS workflow guidance, the
Gest/Codex playbook, and reusable tools. Keep project-specific details out of
the template.

## Completion

Verify before completing tasks. Complete the leaf task only after verification.
For non-trivial leaf tasks, add a concise completion note before marking the
task done. Keep the original description as the task intent; use notes for what
actually happened.

```bash
gest task note add <id> --agent codex --body "Done: ...\nVerification: ...\nFollow-up: ..."
gest task complete <id> --quiet
```

Use `Done` and `Verification` in every completion note. Add `Follow-up` only
when there is a real residual issue or next step. Use metadata for
machine-queryable facts, not prose summaries.

Update parent notes/status when useful, but leave outline parents open unless
the whole subtree is done.

Before final response for any substantial task, perform a dirty-worktree gate:
`git status --short --branch` for every repo you edited. If a repo has
Codex-owned changes and any commit-required checkpoint trigger applies, do not
finalize yet; run `gcm` or record a specific no-commit reason. A completed Gest
leaf is not a substitute for a Git checkpoint.

Final responses should include relevant Gest IDs, files changed, verification
commands/results, and any GitHub issue URL.
