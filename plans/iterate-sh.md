---
status: active
---

# iterate.sh - shell script driving the ralph loop

A shell script that implements the ralph loop by calling
`prompts/iterate.md` on a plan file, parsing the output action,
and dispatching to the appropriate prompt (`plan.md`,
`implement.md`) in a loop until done or requiring human input.

## Context

### Decided

- **Invoke claude via `claude-jail.sh`** at
  `$(jj root)/dotfiles/emacs/lisp/claude-code/claude-jail.sh`.
  This wraps `claude -p` through jexec. Not through
  `claude-run.sh` - iterate.sh is the outer loop.
- **On `feedback`, stop iterating.** Print what needs human input
  and exit. The script is non-interactive. plan.md sets `feedback`
  when it adds open questions that block progress. implement.md
  sets `feedback` when a task can't be completed as written.
  iterate.sh reads the status after each step and stops when it
  sees `feedback`.

- **Commit after each step that modifies files.** Each step is
  atomic and represents progress. The existing "do not commit"
  rule in individual prompts applies to interactive use - the
  automated loop owns the commit cycle.
- **iterate.sh owns commits directly.** Simple mechanical
  messages like `[WIP] iterate: plan iterate-sh` - these are
  progress checkpoints, not final history. The human rewrites
  messages before promoting. This avoids a dependency on
  commit-prompt.md, which is about crafting good final commit
  messages - a different problem. Use the full plan file path
  as given on the command line - a simple record of action and target.

## Goal

Create `iterate.sh` - a POSIX shell script that takes a plan
file as input and drives it through the ralph loop automatically.
The script calls `claude -p` with `prompts/iterate.md` to decide
the next action, then dispatches to the appropriate prompt
(`plan.md` or `implement.md`) via `claude -p`, repeating until
the plan is done or human input is needed.

## Tasks

- [x] Create `iterate.sh` with argument parsing and the main loop
  skeleton. Accept a plan file path as the single argument. Validate
  it exists. Set up `CLAUDE` variable pointing to `claude-jail.sh`
  via `$(jj root)`. The main loop calls `claude -p prompts/iterate.md`
  with the plan file on stdin, parses the `%iterate%:` output line,
  and dispatches on signal: `continue` routes to the action handler,
  `halt` prints the plan file path and exits, `ok` prints done and
  exits. For now, the `continue` handler just prints the action
  (`plan` or `implement`) and exits - real dispatch comes next.

- [x] Add dispatch to `plan.md` and `implement.md`. When the action
  is `plan`, call `claude -p prompts/plan.md` with the plan file.
  When the action is `implement`, call `claude -p prompts/implement.md`
  with the plan file. Single-pass - dispatch once and exit.

- [ ] Add commit-after-step. After each dispatch call, check if jj
  shows modified files (`jj status`). If yes, commit with
  `jj commit -m '[WIP] iterate: <action> <plan-file>'` where
  action is `plan` or `implement` and plan-file is the full path
  as given on the command line. Use the repo lock
  (`lockf -k "$(jj root)/.jj/claude.lock"`) around jj operations.

## Done-when

- `iterate.sh` is a working POSIX shell script at the repo root
- Given a draft plan, it loops: calls iterate.md to route, dispatches
  to plan.md or implement.md, commits after changes, repeats
- Stops on `%iterate%:ok` (plan done) or `%iterate%:halt:feedback`
  (needs human input)
- Commits use `[WIP] iterate: <action> <plan-file>` format with full path
- All jj operations use lockf for concurrency safety
