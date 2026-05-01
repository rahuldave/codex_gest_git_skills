---
name: grv
description: Gest Review. Review the current Git changeset for correctness, safety, regressions, style, and missing tests, with findings first.
---

# GRV: Gest Review

Use for code-review stance.

## Workflow

Inspect:

```bash
git diff
git diff --staged
```

If reviewing a commit, diff that commit directly.

Report findings first, ordered by severity, with file/line references. Focus on
bugs, behavioral regressions, safety, error handling, and missing tests. If no
issues are found, say so and mention residual risk or test gaps.
