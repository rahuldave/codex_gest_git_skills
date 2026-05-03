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

In development mode, do not default to asking the user whether a verified slice
should be committed. Make the judgment yourself after each coherent depth-2
implementation leaf or tightly related set of leaves. Prefer committing before
continuing when the slice changes schema, persistence, query semantics, public
APIs, user-visible UI, or non-trivial verification. Keep the unit small enough
that `git bisect` would land on a useful layer.

Use completed Gest task notes to draft copious but focused commit bodies:
include what changed from `Done`, the exact checks from `Verification`, and any
real `Follow-up`. Never include Gest IDs.

After creating a commit, run checkpoint hygiene: regenerate the overall Gest
graph and a focused graph for the latest relevant iteration, serialized away
from `gest` commands. For any code commit, ensure `grv` has happened after the
code change or run it immediately. Also make and verify a push/sync decision:
`git push` is separate from GitHub issue promotion. For development depth-1
parents or development iterations, run the explicit `gpr` decision: create/sync
the GitHub issue and record metadata, or record why promotion was skipped.
Report graph paths, the commit hash, final branch relationship, push status,
review status, and the GitHub issue decision.

## Workflow

Inspect:

```bash
git status --short --branch
git diff
git diff --staged
git log --oneline -10
git remote -v
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

Ask the user for confirmation before committing only when the commit checkpoint
is ambiguous, risky, or outside the workflow's durable-checkpoint rules. If the
user has asked you to manage commits or the workflow clearly says the verified
development slice should be committed, proceed. Stage explicit files rather
than using `git add .`.

After committing:

```bash
git status --short --branch
git push
git status --short --branch
```

Push when the branch has an upstream and the user has not asked for local-only
work. If the branch is ahead and you do not push, record the exact reason in the
Gest note and final summary. A checkpoint is not complete while a Codex-created
commit is silently ahead of its upstream. For reusable workflow/template repo
changes, push is mandatory unless blocked.
