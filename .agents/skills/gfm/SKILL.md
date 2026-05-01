---
name: gfm
description: Gest Format. Run formatting, linting, static checks, tests, and smoke checks appropriate to the current project; fix mechanical issues.
---

# GFM: Gest Format

Use to verify and clean a changeset.

## Workflow

1. Identify project and changed files.
2. Run format/lint/static checks/tests appropriate to the project.
3. Fix mechanical issues.
4. Re-run failing checks.

Use the target repository's project-specific verification commands. Common
examples include:

```bash
<format command>
<lint command>
<test command>
git diff --check
```

Report every command run and whether it passed.
