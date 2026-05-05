# Claude Code Instructions

Read `AGENTS.md` first. This repository keeps the reusable Gest workflow
instructions and `g*` skills source of truth in `.agents/skills/` and
`AGENTS.md`.

For substantial coding, debugging, documentation, verification, setup, or
workflow changes, use `/gtw` or the relevant `g*` skill. Keep `.claude/skills`
as an adapter layer that points back to `.agents/skills`; do not make it the
source of truth.
