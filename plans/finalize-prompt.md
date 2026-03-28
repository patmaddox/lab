---
status: draft
---

# Create a finalize prompt

Extract completion handling from implement.md into a dedicated
finalize prompt. Currently implement.md marks a plan as done and
adds a postmortem in the same invocation as checking off the last
task, which bundles two concerns into one commit. Finalize should
be its own step so the completion gets its own commit.

## Goal

A new `prompts/finalize.md` prompt that handles plan completion -
setting status to `done` and adding the Postmortem section. The
iterate loop routes to it when all tasks are checked off. The plan
is not moved to `plans/archive/` - the human writes their part of
the postmortem first.

## Context

The iterate loop (`iterate.sh`) calls `prompts/iterate.md` to
decide the next action, then dispatches to either `plan` or
`implement`. iterate.md is a pure router - it reads state but
never writes. iterate.sh handles committing after each action.

Currently implement.md step 7 fires in the same invocation as
checking off the last task (step 6), bundling the final
implementation and the completion into one commit.

The finalize prompt is a new action in the iterate loop, alongside
plan and implement. iterate.md needs a new rule to detect "all
tasks done, status not `done`" and route to finalize. iterate.sh
needs a new case in its action dispatch.

## Tasks

- [ ] Create `prompts/finalize.md` - checks all tasks are done, sets status to `done`, adds Postmortem section with Claude subsection filled in and Pat subsection left for the human. Does not archive.
- [ ] Remove step 7 (Handle completion) from `prompts/implement.md` - after checking off the last task, implement stops like any other task. Update step 4 to remove the "go to step 7" reference.
- [ ] Update `prompts/iterate.md` rule 5 to output `%iterate%:continue:finalize` instead of `%iterate%:ok`. Add a new rule 6: status is `done`, output `%iterate%:ok`.
- [ ] Add `finalize` case to `iterate.sh` action dispatch that calls `prompts/finalize.md`.

## Done-when

- `prompts/finalize.md` exists and handles setting `done` status and adding postmortem
- `prompts/implement.md` no longer handles completion
- `prompts/iterate.md` routes to finalize when all tasks are checked
- `iterate.sh` dispatches the finalize action
- The iterate loop produces a separate commit for finalization
