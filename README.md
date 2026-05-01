# Codex Gest Git Skills

Reusable Codex skills, agent instructions, and small tools for working with
Gest-tracked projects in Git repositories.

This repository is meant to be mixed into other repos. It keeps the workflow
version-controlled without making every project reinvent the same `gtw`, `gim`,
`gcm`, and related skills.

## What Is Included

- `.agents/skills/g*`: project-local Codex skills for Gest workflow routing,
  planning, implementation, review, formatting, promotion, orchestration, and
  commits.
- `AGENTS.template.md`: starter agent instructions to copy into a target repo.
- `docs/gest_codex_workflow.md`: the full workflow playbook.
- `tools/gest_mermaid_graph.py`: optional read-only Gest SQLite exporter that
  writes clickable Mermaid/HTML relationship graphs.
- `scripts/install.sh`: simple copy-based installer for target repos.

## Install Into A Repo

From this repository:

```bash
scripts/install.sh /path/to/target/repo
```

The installer copies:

```text
.agents/skills/g*
docs/gest_codex_workflow.md
tools/gest_mermaid_graph.py
AGENTS.template.md -> AGENTS.md, only if AGENTS.md does not already exist
```

Review `AGENTS.md` after installing and replace placeholders such as project
name, verification commands, and GitHub policy.

## Workflow Shape

Use `gtw` as the default router for substantial project work. It decides:

- whether work is session-shaped or development-shaped
- whether a spec is needed before implementation
- which durable Gest parent task should own the request
- which tags and metadata apply
- whether parallel worktrees/subagents are appropriate
- whether GitHub issue promotion is appropriate
- whether a commit checkpoint has been reached

Gest descriptions record intent. Non-trivial completed leaf tasks should get a
task note before completion:

```bash
gest task note add <task-id> --agent codex --body "Done: ...\nVerification: ..."
gest task complete <task-id> --quiet
```

Committing is VCS hygiene, not a Gest task by itself. Session work does not
auto-commit every small leaf. Development work should commit at verified durable
checkpoints.

## Publishing This Repo

After creating a GitHub token/session:

```bash
gh auth login -h github.com
gh repo create codex_gest_git_skills --public --source . --remote origin --push
```

