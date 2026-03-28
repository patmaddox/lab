---
status: draft
---

# iterate.sh - shell script driving the ralph loop

A shell script that implements the ralph loop by calling
`prompts/iterate.md` on a plan file, parsing the output action,
and dispatching to the appropriate prompt (`plan.md`,
`implement.md`) in a loop until done or requiring human input.

## Context

### Decided

- **Invoke claude via `claude -p`** using the claude script at
  `$(jj root)/dotfiles/emacs/lisp/claude-code/`. Not through
  `claude-run.sh` - iterate.sh is the outer loop.
- **On `feedback`, stop iterating.** Print what needs human input
  and exit. The script is non-interactive.
- **Commit after each step that modifies files.** Each step is
  atomic and represents progress. The existing "do not commit"
  rule in individual prompts applies to interactive use - the
  automated loop owns the commit cycle.
- **iterate.sh owns commits directly.** Simple mechanical
  messages like `[WIP] iterate: plan iterate-sh` - these are
  progress checkpoints, not final history. The human rewrites
  messages before promoting. This avoids a dependency on
  commit-prompt.md, which is about crafting good final commit
  messages - a different problem.

## Goal

Create `iterate.sh` - a POSIX shell script that takes a plan
file as input and drives it through the ralph loop automatically.
The script calls `claude -p` with `prompts/iterate.md` to decide
the next action, then dispatches to the appropriate prompt
(`plan.md` or `implement.md`) via `claude -p`, repeating until
the plan is done or human input is needed.
