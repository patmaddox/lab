---
status: done
---

# Create a prompt for implementing plans

## Goal

Create `prompts/implement.md` -- an LLM-executable prompt that
picks up the next uncompleted task in a plan, implements it with
the simplest possible solution, and checks it off.

## Context

prompts/plan.md handles the development side -- iterating on a plan
until it's ready. There is no prompt for the execution side. The
implementation instructions currently live in the Plans section of
CLAUDE.md (lines ~155-173) and need a proper home as a standalone
prompt.

The prompt should follow the same structural conventions as
prompts/plan.md: a self-contained document that an LLM reads and
follows, with clear steps and rules.

Source material for the prompt content:
- CLAUDE.md "Executing a plan" section (current instructions)
- CLAUDE.md "Checking dependencies" section
- plans/archive/prompt-plan.md (example of a completed plan with
  postmortem)

### Decided

- The implementer does not modify the plan. If reality diverges
  from the spec (a task is wrong, unclear, or blocked), it stops
  and tells the human that more planning is needed. No automated
  loop back to the plan prompt.
- Task progress is tracked by checking items off in the plan file.
  The human decides when to commit.
- The prompt works on one task per invocation -- the next
  uncompleted task. It does not try to implement the whole plan.
  It produces the simplest possible solution to accomplish the task.
- The human handles archiving. The prompt does not move files or
  regenerate INDEX.md.
- When all tasks are checked off, the prompt writes a Postmortem
  section (Claude subsection filled in, Pat subsection left blank).
- The implementer manages plan status: set to `active` on first
  invocation, set to `done` only when all tasks are complete.

## Tasks

1. [x] Write `prompts/implement.md` covering these concerns:
   - Read the plan and verify it is ready (four sections present)
   - Check that `depends` plans are satisfied (status is done)
   - Find the next unchecked task
   - Implement it with the simplest possible solution
   - Check it off in the plan file
   - If the task can't be completed as written, stop and tell the
     human that more planning is needed
   - Set status to `active` on first invocation (if not already)
   - When all tasks are done, set status to `done` and write a
     Postmortem section

## Done-when

- `prompts/implement.md` exists and covers: dependency check,
  single-task execution, progress tracking, stop-on-divergence,
  and postmortem writing
- Style and structure are consistent with prompts/plan.md
- The prompt does not duplicate instructions that CLAUDE.md already
  provides (commit conventions, repo structure, etc.) -- it
  complements CLAUDE.md rather than replacing it

## Postmortem
### Claude
Straightforward single-task plan. The main design work was deciding
how to structure the steps -- landed on a linear flow (verify, check
deps, set active, find task, implement, check off, handle completion)
that mirrors how plan.md structures its passes. Kept the rules section
tight to avoid duplicating CLAUDE.md conventions. The plan's Decided
section made every judgment call clear, so there was nothing to guess.
### Pat
(filled in by Pat after reviewing the work)
