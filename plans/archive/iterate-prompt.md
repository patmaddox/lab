---
status: done
---

# Create an iterate prompt that combines plan, implement, refactor

A higher-level prompt that drives the full cycle: develop a plan
until it's ready, implement it, then refactor. The interesting
question is how the steps interact - implementation may reveal
that the plan was wrong, requiring a return to planning. Refactoring
may surface new work that needs planning.

## Goal

Create `prompts/iterate.md` - a router prompt that reads a plan
file's current state and outputs `%iterate%:plan`,
`%iterate%:implement`, `%iterate%:feedback`, or
`%iterate%:done`.

## Context

### Output format

The prompt outputs `%iterate%:<action>` on its own line somewhere
in its response. The caller extracts it with:
`awk -F: '$1 == "%iterate%" {print $2}'`

### Existing prompts

- **prompts/plan.md** - develops a plan one step per invocation
  until it has Goal, Context, Tasks, Done-when. Integrates human
  feedback via blockquote annotations.
- **prompts/implement.md** - picks up the next uncompleted task
  from a ready plan, implements it, marks it done. One task per
  invocation. Stops on divergence rather than improvising.

### Prior thinking

The ralph loop (fieldstone) is rough prior thinking on the
plan-implement cycle but not prescriptive.

## Tasks

- [x] Create `prompts/iterate.md` - a router prompt that receives a
  plan file, reads its frontmatter status, checks for open questions,
  checks task completion state, and outputs exactly one
  `%iterate%:<action>` line. Decision logic:
  - Open questions exist -> `%iterate%:feedback`
  - Status is `draft` -> `%iterate%:plan`
  - Status is `ready` or `active`, uncompleted tasks remain ->
    `%iterate%:implement`
  - All tasks completed -> `%iterate%:done`
  - Implementation flagged divergence (plan returned to `draft`) ->
    `%iterate%:plan`
  Follow the structure and voice of existing prompts (plan.md,
  implement.md): numbered steps, rules section, clear boundaries.

## Done-when

- `prompts/iterate.md` exists and follows the structure of existing
  prompts (numbered steps, rules section)
- The prompt outputs exactly one `%iterate%:<action>` line per
  invocation, where action is one of: `plan`, `implement`,
  `feedback`, `done`
- Decision logic covers all five cases in the task (open questions,
  draft, ready/active with remaining tasks, all tasks complete,
  divergence returning to draft)
- A caller can extract the action with:
  `awk -F: '$1 == "%iterate%" {print $2}'`

## Postmortem

### Claude

The plan was a single well-defined task with clear decision logic
spelled out. The existing prompts (plan.md, implement.md) provided
a strong template for structure and voice. The divergence case
(implementation sets plan back to draft) didn't need special handling -
it falls naturally out of checking status as `draft` in rule 2.

### Pat

Again this seems to have gone well. I haven't actually run it yet, so
we'll see.
