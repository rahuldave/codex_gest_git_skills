---
name: gpl
description: Gest Plan. Decompose a spec, outline task, or GitHub-backed initiative into Gest tasks, dependencies, phases, and session/development iterations.
---

# GPL: Gest Plan

Use to convert a spec or outline task into executable Gest structure.

## Inputs

Accept a Gest artifact ID, task ID, GitHub issue URL/number, or user-described
scope. Read the entity with `gest ... show --json` when possible.

## Decisions

1. Is this a session plan or development plan?
2. What is the outline parent?
3. What depth should new tasks have?
4. Which tasks are independent?
5. Which phases and `blocked-by` links are needed?
6. Should GitHub metadata be attached?

## Output Structure

Create tasks with native `child-of` links:

- depth 1: `issue`
- depth 2: `subissue` or concrete implementation leaf
- depth 3: tiny subtasks only when useful

Create or update an iteration and add tasks with explicit phases. Tasks in the
same phase must be safe to run concurrently.

Report task IDs, phase grouping, dependencies, and whether `gor` can parallelize
the work.
