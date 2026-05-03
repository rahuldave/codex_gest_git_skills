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
6. Run `gfm` for formatting, linting, typechecking, compile/static checks, and
   diff hygiene.
7. Run `gte` for focused unit/API regression tests, smoke checks, and
   integration/browser checks appropriate to the changed behavior. Any changed
   callable code needs tests; smoke checks alone are not enough.
8. Run `gdo` when user docs, developer docs, workflow docs, examples, or command
   references are affected.
9. Run `grv` after every code change, even for quick development without a pull
   request. Fix or record findings before completion.
10. For non-trivial leaf tasks, add a completion note before completion. Preserve
   the task description as intent; record what actually happened in the note:

```bash
gest task note add <id> --agent codex --body "Done: ...\nVerification: ...\nFollow-up: ..."
```

Use `Done` and `Verification` in every completion note. Add `Follow-up` only
when there is a real residual issue or next step.

11. Complete the task only after verification, review, and the completion note:

```bash
gest task complete <id> --quiet
```

Update parent notes/status when useful. Do not complete long-lived outline
parents unless the full subtree is done.

## Checks

Use project-local commands. A typical Python/web project may include:

```bash
uv run ruff check .
uv run ty check
uv run python -m compileall <packages> <scripts>
uv run pytest tests regression_tests
uv run python scripts/smoke_check.py
git diff --check
```

Use `integration_tests/` scripts or direct browser-agent checks for frontend,
UI, and interaction changes. If no durable integration script exists for a
repeated browser flow, record that follow-up.
