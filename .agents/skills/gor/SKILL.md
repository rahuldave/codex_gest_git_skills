---
name: gor
description: Gest Orchestrate. Execute a phased Gest iteration, deciding per phase whether work should run sequentially or in parallel git worktrees/subagents.
---

# GOR: Gest Orchestrate

Use for a phased iteration. Works for both session and development iterations.

## Workflow

1. Read iteration:

```bash
gest iteration show <id> --json
gest iteration status <id> --json
gest iteration graph <id>
gest project --json
```

2. Group tasks by phase.
3. Decide execution strategy:
   - single task: run `gim` locally
   - dependent tasks: run sequentially by phase
   - independent code-touching tasks: use git worktrees/subagents
4. Claim with:

```bash
gest iteration next <id> --claim --agent <agent-name> --json
```

Exit code 75 means no task is currently available.

5. For parallel work, create one git worktree per task, attach it to the same
   Gest project, run implementation, integrate results, and clean up.
6. Advance phases only after current-phase tasks are terminal.
7. Report successes, failures, and remaining tasks.

Do not parallelize just because there are multiple tasks. Parallelize only when
task independence and file ownership make it useful.
