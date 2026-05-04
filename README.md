# Codex Gest Git Skills

Reusable Codex skills, agent instructions, and small tools for working with
Gest-tracked projects in Git repositories.

This repository is meant to be mixed into other repos. It keeps the workflow
version-controlled without making every project reinvent the same `gtw`, `gim`,
`gpa`, `gcm`, and related skills.

## What Is Included

- `.agents/skills/g*`: project-local Codex skills for setup, Gest workflow routing,
  planning, implementation, review, formatting, testing, docs, promotion,
  pull request acceptance, orchestration, and commits.
- `AGENTS.template.md`: starter agent instructions to copy into a target repo.
- `docs/gest_codex_workflow.md`: the full workflow playbook.
- `docs/g_commands_cheatsheet.md`: quick user-facing guide to `/gtw` and the
  other g-command skills.
- `docs/gsu_typescript_hello_world.md`: disposable setup lab for a tiny
  TypeScript project using `gsu` concepts and `just` command contracts.
- `docs/gest_gitbutler_workflow_guide.md`: user-facing setup and practice guide
  for Gest, the g skills, GitButler stacks, and physical worktrees.
- `tools/gest_mermaid_graph.py`: optional read-only Gest SQLite exporter that
  writes clickable Mermaid/HTML relationship graphs.
- `scripts/install.sh`: simple copy-based installer for target repos.
- `templates/`: composable setup snippets for `.gitignore`, `.envrc`,
  `.env.example`, and common `Justfile` targets.

## Install Into A Repo

From this repository:

```bash
scripts/install.sh /path/to/target/repo
```

The installer copies:

```text
.agents/skills/g*
docs/*.md
tools/gest_mermaid_graph.py
AGENTS.template.md -> AGENTS.md, only if AGENTS.md does not already exist
```

Review `AGENTS.md` after installing and replace placeholders such as project
name, verification commands, and GitHub policy.
Use `templates/` as `gsu` inputs when creating `.gitignore`, `.envrc`,
`.env.example`, or `Justfile` command contracts.

For a small setup-first example, read
[`docs/gsu_typescript_hello_world.md`](docs/gsu_typescript_hello_world.md).

To learn the workflow by hand, read
[`docs/gest_gitbutler_workflow_guide.md`](docs/gest_gitbutler_workflow_guide.md)
and run its disposable-repo lab. It walks through Gest setup, skill
responsibilities, branch/stack/worktree decisions, GitButler sequential stack
practice, and physical worktree integration.

## Workflow Shape

Use `gtw` as the default router for substantial project work. It decides:

- whether work is session-shaped or development-shaped
- whether a spec is needed before implementation
- which durable Gest parent task should own the request
- which tags and metadata apply
- which branch model and execution model should own write changes
- whether parallel physical worktrees/subagents are appropriate
- whether GitHub issue promotion is appropriate
- whether a commit checkpoint has been reached

Use `gsu` when bootstrapping a repository or refreshing its workflow contract.
It helps choose tools, set up Git/Gest/Just/direnv expectations, create ignore
rules, install or sync dependencies through the chosen package manager, and map
project concepts such as lint, typecheck, test, build, smoke, docs, and run-app
commands in `AGENTS.md`.

Gest descriptions record intent. Non-trivial completed leaf tasks should get a
task note before completion:

```bash
gest task note add <task-id> --agent codex --body "Done: ...\nVerification: ..."
gest task complete <task-id> --quiet
```

Committing is VCS hygiene, not a Gest task by itself. Session work does not
auto-commit every small leaf. Development work should commit at verified durable
checkpoints. Session classification alone is not a reason to skip `gcm` for
deployment/runtime config, persistence, public API, user-visible UI, reusable
workflow/template changes, publishable docs, or non-trivial multi-file verified
changes. Before final response for substantial work, inspect
`git status --short --branch`; if Codex-owned changes remain and one of those
triggers applies, run `gcm` or record the concrete no-commit reason.

## Branch, Stack, And Worktree Policy

For Gest-tracked writes, keep `main` integration-ready and choose both a branch
model and an execution model before editing. Normal session or development work
uses `session/<task-id>-summary` or `gest/<task-id>-summary` branches. Multiple
meaty dependent slices should use stacked branches or stacked PRs. Multiple
independent slices that run at the same time should use separate physical git
worktrees.

GitButler support is sequential by default. GitButler parallel branches and
stacked branches share one managed workspace, so they are branch-curation tools,
not the agent-parallelism primitive. Do not launch parallel write agents in one
GitButler workspace and do not use GitButler parallel lanes for agent
parallelism. If work must run in parallel, use physical worktrees first, then
integrate the results into the intended branch or stack.

In GitButler-managed mode, use current `but` CLI write commands such as
`but branch new`, `but stage`, `but commit`, `but push`, and `but pr`. Do not
use raw `git commit`, `git switch`, `git checkout`, or branch-mutating git
commands while GitButler owns the workspace.

## Publishing This Repo

After creating a GitHub token/session:

```bash
gh auth login -h github.com
gh repo create codex_gest_git_skills --public --source . --remote origin --push
```
