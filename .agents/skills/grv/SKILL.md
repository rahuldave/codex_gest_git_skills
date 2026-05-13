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

If the checkout is GitButler-managed, also inspect branch ownership:

```bash
but status
but diff
but branch list --all
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
bugs, behavioral regressions, safety, error handling, and missing tests. Treat
`Findings: None` as a precise statement about blocking or actionable code-review
findings, not as the whole review.

After findings, add reviewer judgment when it would help the user: call out
non-blocking opinions about clarity, maintainability, UX, naming, fit with local
patterns, or tradeoffs. Label these separately from findings so taste-level
feedback does not look like a merge blocker. If no issues are found, say so,
then still mention residual risk, test gaps, and any useful non-blocking
observations.

Missing focused tests for changed callable code or APIs are review findings, not
just nice-to-have follow-ups.

For workflow changes, review VCS safety as behavior: flag any instruction that
allows raw `git commit`/`git switch`/`git checkout` in GitButler mode, any plan
that launches parallel write agents in one GitButler workspace, or any stacked
branch flow that lacks bottom-up integration/review guidance.

## Tag And Dependency Findings

Review the current changes against `docs/tag_dependency_workflow.md`. If code contracts changed, inspect the `ast-grep` patterns that were run and the dependers they found. Treat missing `ast-grep` dependency-impact checks, unhandled dependent surfaces, or missing focused tests for found dependers as review findings.
