---
name: gfm
description: Gest Format. Run formatting, linting, typechecking, compile/static checks, and mechanical diff hygiene; fix mechanical issues. Use gte for tests and gdo for documentation.
---

# GFM: Gest Format

Use to mechanically clean and statically check a changeset. `gfm` does not own
runtime tests or documentation checks; route those to `gte` and `gdo`.

## Workflow

1. Identify project and changed files.
2. Run formatting, linting, typechecking, compile/static checks, and diff
   hygiene appropriate to the project.
3. Fix mechanical issues.
4. Re-run failing checks.
5. Report every command run and whether it passed.

Use the target repository's project-specific verification commands. Common
examples include:

```bash
<format command>
<lint command>
<typecheck command>
<compile/static command>
git diff --check
```

Do not substitute smoke checks for `gte`.
