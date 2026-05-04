# Gest g-Commands Cheat Sheet

This cheat sheet is for users working in a repository that has the reusable
Codex/Gest skills installed. Use these commands in natural language, for
example `/gtw fix the search bug`, `$gtw plan annotation import`, or
`gcm: commit the verified slice`.

For a setup-focused TypeScript hello-world lab, read
[`gsu_typescript_hello_world.md`](gsu_typescript_hello_world.md). For verified
Python, TypeScript, Go, and Rust profile labs, read
[`gsu_language_profile_labs.md`](gsu_language_profile_labs.md). For the longer
explanation and hands-on Git/GitButler reproduction lab, read
[`gest_gitbutler_workflow_guide.md`](gest_gitbutler_workflow_guide.md).

## Start Here: `/gtw`

`/gtw` means **Gest Track Work**. It is the normal entry point for substantial
coding, debugging, implementation, refactoring, documentation, verification,
GitHub planning, or project work.

Use `/gtw` when you want Codex to take responsibility for the whole workflow,
not just answer a question. It will:

- inspect existing Gest tasks, iterations, specs, and project context
- classify the request as session work or development work
- decide whether a spec is needed before implementation
- choose or create the right durable parent task
- create and claim concrete leaf tasks before edits
- choose a branch model and execution model for write changes
- decide whether GitHub issue promotion is appropriate
- route to the right specialized g-command
- decide when verified work should be committed
- run checkpoint hygiene at durable checkpoints

A good default prompt is:

```text
/gtw <what you want changed or investigated>
```

## Commands Routed From `/gtw`

`/gtw` may call or follow the workflow of these more specific commands:

| Command | Name | Use When |
| --- | --- | --- |
| `gbs` | Gest Brainstorm | The idea is fuzzy and needs exploration, trade-offs, or clarifying questions. |
| `gsu` | Gest Setup | A repo needs bootstrap, tool selection, installs, ignore rules, Justfile targets, or AGENTS.md command-contract mapping. |
| `gsp` | Gest Spec | The work needs a product/design spec before implementation. |
| `gpl` | Gest Plan | A spec, outline task, or GitHub-backed initiative needs to be decomposed into tasks, phases, and dependencies. |
| `gis` | Gest Issue | A durable Gest outline task or subtask needs to be created or updated. |
| `gpr` | Gest Promote | Durable work should be promoted or synced to a GitHub issue. |
| `gim` | Gest Implement | One concrete Gest task should be implemented end to end. |
| `gor` | Gest Orchestrate | A phased iteration should be executed, possibly with parallel worktrees/subagents. |
| `grv` | Gest Review | Current changes or a commit need code-review-style findings. |
| `gfm` | Gest Format | Formatting, linting, typechecking, static checks, or mechanical fixes are needed. |
| `gte` | Gest Test | Unit, API regression, smoke, regression, or integration tests are needed. |
| `gdo` | Gest Docs | User-facing, developer-facing, or in-code docs need to be checked and updated. |
| `gpa` | Gest PR Accept | A GitHub PR needs review, Gest context, approval/merge guidance, or post-merge bookkeeping. |
| `gcm` | Gest Commit | A verified checkpoint should be committed with an appropriate message. |

## Quick Decision Guide

Use `/gtw` for most real project work. Use a specific g-command when you already
know the stage you want.

- Use `gbs` when you are still thinking: "what should this feature be?"
- Use `gsp` when behavior is unclear or multi-system.
- Use `gpl` when there is a spec but no task breakdown.
- Use `gis` when the durable task tree needs shaping.
- Use `gpr` when the work should be visible on GitHub.
- Use `gim` when one claimed leaf task is ready to implement.
- Use `gor` when an iteration has multiple phases or parallelizable tasks.
- Use `grv` when you want bugs and risks, not a summary.
- Use `gfm` when you want mechanical checks and fixes.
- Use `gte` when you want behavioral tests run or added.
- Use `gdo` when docs or code documentation may need to be created or updated.
- Use `gpa` when a pull request should be reviewed as a Gest-tracked
  workstream before approval or merge.
- Use `gcm` when the work has reached a verified commit checkpoint.

## Typical Flows

### Small Bug

```text
/gtw fix the tag-only search bug
```

Likely path:

```text
gtw -> inspect existing tasks -> create/claim leaf -> gim -> gfm -> gte -> grv -> gcm
```

### Large Feature

```text
/gtw add cross-book search with tags and full text
```

Likely path:

```text
gtw -> gbs or gsp -> gpl -> gis -> gim/gor -> gfm -> gte -> gdo -> grv -> gcm -> gpr decision
```

### Planning Only

```text
gpl: break the search spec into implementation phases
```

Likely path:

```text
gpl -> create/update tasks, phases, dependencies, and iteration metadata
```

### Review Only

```text
grv: review the current changeset
```

Likely path:

```text
grv -> findings first -> open questions -> brief summary
```

### Pull Request Acceptance

```text
gpa: review PR #12 and add missing Gest context
```

Likely path:

```text
gpa -> gh pr view/diff/checks -> Gest task/artifact lookup -> PR findings -> human checklist -> optional PR body update -> approve/merge recommendation
```

## Commit And Checkpoint Habits

For development work, Codex should not wait until a whole large feature is done
before committing. After each verified coherent depth-2 implementation slice,
Codex should judge whether the slice is commit-worthy. Schema, persistence,
query/API, UI, and non-trivial verification slices usually deserve separate
commits.

Commit bodies should be based on completed Gest notes:

```text
Done: what changed
Verification: commands/checks run
Follow-up: real residual issues only
```

At durable checkpoints, Codex should also:

- regenerate the overall Gest graph
- regenerate a focused graph for the latest relevant iteration
- run the explicit GitHub promotion/sync decision for development parents and
  iterations
- run an explicit review pass after every code change
- report graph paths, commit hashes, review status, and GitHub issue decision

## Branch And Stack Habits

For Gest-tracked writes, Codex should keep the branch/review model separate from
the execution model:

- one coherent session or development workstream: one branch, possibly multiple
  meaningful commits
- several meaty dependent slices: stacked branches or stacked PRs
- several independent slices running at the same time: physical worktrees

GitButler support is sequential by default. GitButler parallel branches and
stacked branches share one managed workspace, so agents should not use
GitButler parallel lanes for concurrent writes. If concurrent write work is
needed, use separate physical worktrees, then integrate the results into the
intended branch or stack afterward.

In GitButler-managed mode, Codex should write with `but` commands such as
`but branch new`, `but stage`, `but commit`, `but push`, and `but pr`, not raw
`git commit`, `git switch`, `git checkout`, or branch-mutating git commands.

The full guide includes a disposable-repo lab that repeats these flows:

- GitButler plain branch
- multi-commit session branch
- GitButler stacked base/child branches
- physical git worktrees integrated by rebase and fast-forward

## Naming Notes

The user may write `/gtw`, `$gtw`, or `gtw:`. Treat them as the same natural
language request unless the surrounding UI intercepts slash commands before
Codex sees them.

The commands are skills, not shell commands. They guide how Codex should use
Gest, Git, GitHub, tests, and the local repository.
