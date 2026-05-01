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
