---
name: gim
description: Gest Implement. Implement one concrete Gest task end to end: read, claim, split if too broad, edit, verify, review/format as appropriate, and complete.
---

# GIM: Gest Implement

Use for one concrete implementable Gest task.

## Workflow

1. `gest task show <id> --json`
2. If the task is too broad, stop and split it with `gpl`/`gis`.
3. Claim it: `gest task claim --as codex <id> --quiet`
4. Inspect relevant code and docs.
5. Make scoped edits.
6. Verify with project-appropriate commands.
7. Run `grv` and `gfm` when risk warrants it.
8. For non-trivial leaf tasks, add a completion note before completion. Preserve
   the task description as intent; record what actually happened in the note:

```bash
gest task note add <id> --agent codex --body "Done: ...\nVerification: ...\nFollow-up: ..."
```

Use `Done` and `Verification` in every completion note. Add `Follow-up` only
when there is a real residual issue or next step.

9. Complete the task only after verification and the completion note:

```bash
gest task complete <id> --quiet
```

Update parent notes/status when useful. Do not complete long-lived outline
parents unless the full subtree is done.

## Close Reading Checks

From `close_reading/`:

```bash
uv run ruff check .
node --check app/static/app.js
uv run python -m compileall app scripts
uv run python scripts/smoke_check.py
git diff --check
```
