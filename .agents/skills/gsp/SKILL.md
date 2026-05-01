---
name: gsp
description: Gest Spec. Draft or update a Gest spec artifact for substantial or unclear work, then ensure implementation happens through follow-on Gest tasks.
---

# GSP: Gest Spec

Use when work needs product/design shaping before implementation.

## When To Spec

Create a spec when behavior is unclear, there are meaningful trade-offs,
acceptance criteria need negotiation, multiple systems are affected, or GitHub
visible development is likely.

## Spec Shape

```markdown
# Spec: <Title>

## Problem Statement
## Proposed Solution
## Scope
### In Scope
### Out of Scope
## Acceptance Criteria
## Open Questions
## References
```

Keep specs concise enough to read quickly.

## Save

Save as a Gest artifact tagged `spec` plus area tags:

```bash
gest artifact create "<title>" --tag spec --tag <area> --body "<body>" --quiet
```

Link to outline tasks where appropriate. Do not implement directly from the
artifact; use `gpl`/`gis` to create follow-on tasks.
