---
name: gsu
description: Gest Setup. Bootstrap or refresh a Gest-tracked repository's agent-operable workflow surface: tool checks, project command contract, Justfile targets, AGENTS.md mappings, docs/test conventions, and setup follow-ups.
---

# GSU: Gest Setup

Use when a repository needs first-time setup, workflow refresh, command-contract
normalization, project tool selection, or migration toward reusable Gest/Codex
skills.

`gsu` deals in project concepts. It should not bake one language, package
manager, or test runner into the reusable skills. Instead, it helps the user
choose tools, records those choices in `AGENTS.md`, and creates or updates the
executable command interface, preferably a `Justfile`.

## Core Concepts

Identify which of these concepts apply to the project:

- environment bootstrap
- VCS initialization
- ignore rules
- dependency installation
- local tool installation
- run app or service
- format
- lint
- typecheck
- static or compile check
- build
- unit tests
- regression tests
- integration tests
- smoke checks
- browser spot checks
- browser/UI verification
- database/migration checks
- API docs
- user docs
- internal/developer docs
- release or CI checks

## Workflow

1. Inspect the repository shape: VCS state, `.gitignore`, `AGENTS.md`,
   existing `.agents/skills`,
   `Justfile`, `.envrc`, package manifests, lockfiles, CI configs, docs, test
   directories, source directories, and app entrypoints.
2. Initialize Git or Gest only when missing and after confirming the desired
   repository root. This repo uses Git-oriented skills; keep jj support in a
   separate parallel skill repository.
3. Check required workflow executables: `git`, `gest`, and `just`. Treat
   `direnv` as recommended unless the project contract requires it.
4. Infer likely project profiles from files and user context. Examples:
   - Python: `pyproject.toml`, `uv.lock`, `pixi.toml`, notebooks, FastAPI,
     Django, Flask, pytest, ruff, ty, pyright, mypy.
   - TypeScript/JavaScript: `package.json`, lockfiles, Vite, Next, ESLint,
     Biome, TypeScript, Vitest, Jest, Playwright.
   - Rust: `Cargo.toml`, Cargo workspaces, clippy, rustfmt, rustdoc.
5. Ask the user to choose when multiple plausible tools exist or installation
   would change the machine or repository. Prefer one concise question at a
   time.
6. Create or update ignore rules for generated files, local environments,
   caches, logs, build artifacts, and project-local tool installs.
7. Install or sync project dependencies through the chosen package manager when
   the user approves.
8. Define the project command contract in `AGENTS.md`. Map each applicable
   concept to the command agents should run, including focused arguments.
9. Create or update the `Justfile` when the project uses `just`. Keep target
   names stable and let targets call the project-specific tools.
10. Create or update setup docs, docs/test directory expectations, and
   project-specific invariants in `AGENTS.md`.
11. Run setup verification: command discovery (`just --list`), the cheapest
   static checks, and targeted commands that prove argument passing works.
12. Record remaining setup gaps as Gest follow-ups rather than hiding them.

## Command Contract

Prefer `just` targets when present. `AGENTS.md` should say which command maps
to each workflow concept and how arguments are passed. A typical contract might
include:

```text
Format: just fmt [path]
Lint: just lint [path]
Typecheck: just typecheck
Static/compile check: just static
Build: just build
Focused tests: just test [target]
Full tests: just test
Smoke checks: just smoke
Run app: just dev [port]
Browser spot check: just browser [url-or-flow]
Integration flow: just integration [flow]
Docs check: just docs
```

The reusable `gfm`, `gte`, and `gdo` skills should read this project contract
instead of hard-coding language tools.

## Tool Installation Policy

Use the project package manager where possible. Examples:

- Python: prefer `uv`, `pixi`, or the tool already chosen by the project.
- TypeScript/JavaScript: prefer the detected package manager (`pnpm`, `npm`,
  `bun`, or `yarn`) and use package-manager exec commands.
- Rust: prefer `rustup`/`cargo` conventions already present in the project.

For tools that should be available only inside this repository, prefer an
explicit project-local path such as `.local/bin` exposed through `.envrc`:

```sh
PATH_add .local/bin
```

Do not silently rely on ambient global tools when the project contract says a
local toolchain is required. If installation needs network or writes outside
the sandbox, request approval and explain the tool being installed.

For npm projects, prefer a project-local cache when the user wants explicit
per-project tooling or the global npm cache is unreliable:

```just
export npm_config_cache := ".local/npm-cache"
```

## Profile Notes

For a simple Node-targeted TypeScript project, a good starting profile is:

- package manager: `npm` unless another lockfile is present
- formatter/linter: Biome for a small single-tool default, or the project's
  existing ESLint/Prettier setup
- typecheck/build: TypeScript
- tests: Node's built-in `node:test` for tiny projects, or the detected test
  runner for existing projects
- dev dependencies: `typescript`, `@types/node`, and the chosen formatter/linter
- lint defaults: source and config files, not generated outputs such as `dist/`

## Browser Setup

When a project has browser UI, ask the user whether browser-agent checks should
be part of the command contract. Prefer `npx agent-browser` for a simple
project-local/on-demand setup:

```just
browser-setup:
  npx agent-browser install

browser url="http://127.0.0.1:3000":
  npx agent-browser open {{url}}
```

If the team wants the faster global CLI, document and verify:

```bash
npm i -g agent-browser
agent-browser install
agent-browser skills get core
```

Record which form the project uses in `AGENTS.md`. Keep two browser concepts
separate:

- Browser spot checks: exploratory visual/interaction checks during
  implementation, often run against the current dev server before tests are
  formalized.
- Browser integration tests: durable, rerunnable scripts or tests under
  `integration_tests/`, `e2e/`, or the project's chosen test location.

## Ignore Rules

When creating or refreshing `.gitignore`, cover the project profile without
hiding important source artifacts. Common setup-owned ignores include:

- local environment directories such as `.venv/`
- project-local tool installs such as `.local/`
- language caches such as `.ruff_cache/`, `.pytest_cache/`, `node_modules/`,
  `target/`, and build outputs
- local secrets such as `.env`
- generated logs, coverage outputs, and temporary files

## Just Arguments

Just targets declare parameters after the target name:

```just
lint path=".":
  <lint-command> {{path}}

test target="tests":
  <test-command> {{target}}

dev port="8001":
  <run-command> --port {{port}}
```

Agents pass arguments positionally:

```bash
just lint scripts/foo.py
just test tests/test_foo.py
just dev 8001
```

Use quotes when passing an argument that contains spaces.

## Deliverable

Report:

- detected project profile and chosen tools
- required/recommended executable status
- files created or updated
- command contract mappings
- verification commands run and results
- open follow-ups, especially missing tests, missing docs, or unset CI/hooks
