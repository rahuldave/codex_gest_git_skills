---
name: gpr
description: Gest Promote. Promote or sync durable Gest work with GitHub issues using gh, storing GitHub metadata back on Gest entities.
---

# GPR: Gest Promote

Use when work should become externally visible on GitHub.

## Promotion Criteria

Promote durable user-visible, architecture-relevant, multi-session,
release-worthy, or externally trackable work. Do not promote every leaf task.

## Workflow

1. Read the Gest task/iteration/spec.
2. Sanitize internal details: remove Gest IDs, implementation-only paths, and
   private workflow notes.
3. Draft a GitHub issue body focused on user story, context, acceptance
   criteria, and out-of-scope.
4. Ask the user before running `gh issue create` or `gh issue edit`.
5. Store metadata after creation:

```bash
gest task meta set <id> github.issue <number>
gest task meta set <id> github.url <url>
gest task tag <id> github
```

Also attach metadata to the development iteration when applicable.
