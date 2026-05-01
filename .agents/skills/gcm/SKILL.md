---
name: gcm
description: Gest Commit. Create a Git commit for the current changes, using conventional commit style and GitHub metadata when present.
---

# GCM: Gest Commit

Use when the user asks to commit, or when the Gest workflow says a verified
development checkpoint should be committed.

Committing is VCS hygiene, not a Gest task by itself. Do not create a Gest task
whose only purpose is making a normal commit.

Session-mode work does not auto-commit every small leaf. Prefer committing when
the user asks, when a coherent checkpoint would help, or when a long-lived
parent/subtree reaches a stable point.

Development-mode work should be committed at durable checkpoints: after a
verified depth-1 workstream or coherent depth-2 implementation subtree, before
switching product areas, before handoff, after risky bug/migration work, or
before GitHub issue/PR sync.

## Workflow

Inspect:

```bash
git status
git diff
git diff --staged
git log --oneline -10
```

Draft a conventional commit:

```text
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Never reference Gest IDs in commit messages. If the relevant Gest task metadata
contains `github.issue`, include a GitHub footer such as `Closes #42` only when
that is semantically correct.

Ask the user for confirmation before committing unless they have just explicitly
approved the commit. Stage explicit files rather than using `git add .`.
