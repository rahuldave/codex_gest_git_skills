# Agent Instructions

This repository uses Gest to track substantial implementation work. Use the
project-local Codex skill family under `.agents/skills/`, especially `gtw`, for
coding, debugging, implementation, refactoring, documentation, verification, and
project planning.

The user may invoke the router as `$gtw`, `gtw:`, or `/gtw`.

## Project Context

- Project name: `<replace-me>`
- Main source directory: `<replace-me>`
- Primary docs/specs: `<replace-me>`
- Detailed workflow playbook: `docs/gest_codex_workflow.md`

Replace this section with project-specific invariants, runtime commands, and
verification commands.

## Gest Workflow

Before creating new tasks, search and inspect existing work:

```bash
gest search "<project keyword>" --all --json
gest task list --all --json
gest iteration list --all --json
```

Use native Gest `child-of` / `parent-of` links for hierarchy. Tags are filters,
not hierarchy. Claim one leaf task at a time, verify before completion, and keep
long-lived outline parents open until the whole subtree is done.

For non-trivial completed leaf tasks, add a Gest task note before completion:

```bash
gest task note add <task-id-or-prefix> --agent codex --body "Done: ...\nVerification: ...\nFollow-up: ..."
gest task complete <task-id-or-prefix> --quiet
```

Use task metadata for machine-queryable facts, not prose work logs.

## Commit Cadence

Committing is VCS hygiene, not a Gest task by itself. Do not create a Gest task
whose only purpose is making a normal commit.

Session work should not commit every small leaf by default. Commit when the user
asks, when a coherent checkpoint helps, or when a long-lived parent/subtree
reaches a stable point.

Development work should commit at verified durable checkpoints such as a
completed depth-1 workstream, coherent depth-2 implementation subtree, handoff,
risky bug/migration fix, or GitHub issue/PR sync.

Stage explicit files and do not put Gest IDs in commit messages.

## Verification

Replace with project commands, for example:

```bash
<format command>
<lint command>
<test command>
git diff --check
```

