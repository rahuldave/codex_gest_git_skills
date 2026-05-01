---
name: gbs
description: Gest Brainstorm. Explore rough ideas or ambiguous requests, inspect existing code/docs/Gest context, ask clarifying questions when needed, and decide whether to create a spec, outline issue, plan, or session task.
---

# GBS: Gest Brainstorm

Use when the user has a rough idea, fuzzy feature, or exploratory direction.

## Workflow

1. Inspect local code, docs, and Gest state relevant to the idea.
2. Identify existing patterns, constraints, risks, and open questions.
3. Ask clarifying questions one at a time when needed.
4. Propose 2-3 approaches with trade-offs.
5. Recommend one of:
   - stay in session exploration
   - create/update an outline task with `gis`
   - create a spec with `gsp`
   - plan implementation with `gpl`
   - promote to GitHub with `gpr`

## Gest Use

Brainstorming itself can be tracked as a session leaf when it is part of a
larger workflow. Do not create implementation tasks until the desired behavior
is clear enough to write acceptance criteria.
