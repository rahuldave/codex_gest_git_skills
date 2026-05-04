---
name: grv
description: Gest Review. Review the current Git changeset for correctness, safety, regressions, style, and missing tests, with findings first.
---

# GRV: Gest Review

Use for code-review stance. Run `grv` after every code change before completing
the task, even during quick local development without a pull request.

## Workflow

Inspect:

```bash
git diff
git diff --staged
```

If reviewing a commit, diff that commit directly.

Search Gest for prior regressions, review findings, and browser/test notes in
the touched area:

```bash
gest search "<module/feature> regression" --all --json --limit 20
gest search "<module/feature> review" --all --json --limit 20
gest search "Follow-up <module/feature>" --all --json --limit 20
```

Report findings first, ordered by severity, with file/line references. Focus on
bugs, behavioral regressions, safety, error handling, and missing tests. If no
issues are found, say so and mention residual risk or test gaps.

Missing focused tests for changed callable code or APIs are review findings, not
just nice-to-have follow-ups.
