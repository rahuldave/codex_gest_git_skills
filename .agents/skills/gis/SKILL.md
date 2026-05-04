---
name: gis
description: Gest Issue. Create or update durable Gest outline tasks with user story, context, acceptance criteria, tags, metadata, and child-of links.
---

# GIS: Gest Issue

Use to create or update durable internal Gest tasks. These are Gest issues, not
necessarily GitHub issues.

## Issue Shape

```markdown
## User Story
As a <role>, I want <capability> so that <benefit>.

## Context
Why this matters and any constraints.

## Acceptance Criteria
- [ ] <measurable outcome>

## Out of Scope
- <non-goal>
```

## Create

Use tags and metadata deliberately:

```bash
gest task create "<title>" \
  -d "<issue body>" \
  -l child-of:<parent-id> \
  --tag outline \
  --tag issue \
  --tag <area> \
  --metadata workflow.kind=session \
  --metadata depth=1 \
  --quiet
```

Use `subissue` for lower-level children. Subissues should always have a parent.

For tasks that will write files, include VCS metadata when the branch/execution
shape is known:

```bash
--metadata vcs.tool=git-butler \
--metadata vcs.branch_mode=stacked-development \
--metadata vcs.execution=gitbutler-workspace \
--metadata vcs.parallel_allowed=false
```

Use `vcs.execution=git-worktrees` and a distinct `vcs.workspace_path` per task
when parallel agents will write concurrently. Do not model GitButler parallel
lanes as agent parallelism.
