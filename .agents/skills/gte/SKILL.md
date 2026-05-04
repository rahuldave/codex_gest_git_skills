---
name: gte
description: Gest Test. Run unit, API regression, smoke, regression, and integration tests appropriate to the changed code; add missing tests when the task changes callable behavior.
---

# GTE: Gest Test

Use to verify behavior with executable tests. `gte` owns tests; `gfm` owns
format/lint/typecheck/static checks, and `gdo` owns documentation.

## Test Policy

Any changed callable code needs focused tests near that code. Smoke checks are
not a substitute for inner-function or API regression tests.

Recommended test layout:

- `tests/`: unit tests for inner functions, repositories, parsers, context
  builders, renderers, and other callable code.
- `regression_tests/`: bug and API regression tests that preserve previously
  fixed behavior.
- `integration_tests/`: slower end-to-end or browser-agent-driven checks.

For browser-agent flows that become recurring checks, store the commands in
shell scripts under `integration_tests/` so they can be rerun outside chat
history.

## Workflow

1. Identify changed behavior and the smallest meaningful test layer.
2. Read the project command contract in `AGENTS.md`, especially mappings for
   focused tests, full tests, regression tests, integration tests, smoke checks,
   and browser/UI verification.
3. Search Gest for prior failures, browser-agent audits, smoke-check findings,
   and unresolved follow-ups in the touched area:

```bash
gest search "<feature/module> test" --all --json --limit 20
gest search "browser audit <feature/module>" --all --json --limit 20
gest search "Follow-up <feature/module>" --all --json --limit 20
```

4. Add or update tests for changed inner functions and APIs when coverage is
   missing.
5. Run the relevant focused tests first.
6. Run the broader project test suite.
7. Run smoke checks when they exercise cross-system wiring.
8. Run integration/browser checks for frontend, UI, or interaction changes.
9. Report commands and results. If a layer cannot run, say exactly why.

Prefer `just` targets when the project contract defines them. Typical shapes
include:

```bash
just test [target]
just regression [target]
just integration [flow-or-target]
just smoke
```

If no command contract exists yet, inspect the project manifests and propose or
route to `gsu` to establish one.
