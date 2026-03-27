---
status: ready
---

# Prompt: plan

A prompt that takes a plan file and develops it further -
assessing gaps, filling in detail, asking questions, and
transitioning to `ready` when it's ready to implement.

## Problem

Plans start as stubs (a sentence or two) and need to be developed
into implementable specs. Right now this happens ad hoc in
conversation. A dedicated prompt makes plan development repeatable
and invocable from any context.

## Goal

After implementing this plan:
- A prompt develops any plan file, regardless of interface
- It works from Claude Code TUI, `claude -p`, and potentially
  other coding agents
- Each invocation makes one pass: fills in what it can, asks
  questions about what it can't, modifies the file in place
- The human commits when ready - the prompt does not commit
- Repeated invocations progressively develop the plan as the
  human answers questions and the prompt integrates them
- A plan reaches `ready` when it has Goal, Context, Tasks, and
  Done-when - all concrete enough for an LLM to execute

## Context

### Architecture

The core logic lives in a **prompt file** at
`prompts/plan.md` - a markdown document containing
instructions for how to develop a plan. This is the single
source of truth for what the prompt does.

The prompt file is tool-agnostic. It can be used via:
- **`claude -p`**: e.g. `claude -p @prompts/plan.md plans/myplan.md`
- **Claude Code TUI**: reference the prompt file directly
- **Other coding agents**: any LLM that can read a file

No shell wrapper or skill wrapper needed - the prompt file
itself is the interface. Claude can figure out arguments from
context within the prompt.

### Interaction model

The plan file works like a mailing-list post or format-patch.
The human can annotate any part of the plan by quoting it with
`>` and writing notes below. The prompt then integrates the
feedback - rewriting the quoted section, removing the annotation,
and producing clean prose that incorporates the response.

This applies everywhere in the document, not just Open questions.
If the human disagrees with a task description, they quote it and
say why. If context is wrong, they quote and correct it.

For new questions the prompt needs answered, it adds `>` quoted
questions to the Open questions section. The human replies below
each one.

After a pass, feedback annotations are integrated into the body
and removed. Regular markdown quotes (e.g. quoting an external
source) are left alone. The prompt uses context to distinguish
feedback from legitimate quotes, the same way a human would
reading a mailing list thread.

### Open questions placement

Open questions go at the top of the document, directly after the
summary and before the Problem section. This makes them
immediately visible. If there are no open questions, the section
is omitted entirely.

### Decided

- **Dependencies**: develop the plan anyway, even if `depends`
  plans aren't done. Execution checks dependencies, not planning.
- **Fieldstones**: yes, update fieldstones.org when design
  thinking emerges during development.
- **Task granularity**: commit-sized. Each task should be a
  discrete, reviewable change.
- **No committing**: the prompt modifies the plan file in place
  but does not commit. The human commits when ready.
- **Any status**: the prompt works on plans in any status, not
  just `draft`.
- **Inline review via quoting**: the human can quote (`>`) any
  part of the plan and annotate it. The prompt uses context to
  distinguish feedback from legitimate quotes.
- **Status name**: `ready`, not `accepted`.
- **Prompt file is the interface**: no shell wrapper or skill
  wrapper required. The prompt file is tool-agnostic.
- **Prompt file only for now**: no Claude Code skill wrapper.
  Can add one later if needed.
- **`prompts/` at repo root**: new top-level directory, no need
  to document in CLAUDE.md yet.

## Tasks

1. **Create `prompts/plan.md`** - the prompt file containing
   instructions for developing a plan. Covers: assessment of
   readiness criteria, integrating feedback annotations, filling
   in detail from codebase context, adding questions, and
   transitioning status to `ready`.

2. **Update plan format convention in CLAUDE.md** - document
   that Open questions go after the summary, before Problem.
   If there are no open questions, omit the section.

## Done-when

- The prompt file exists and contains complete instructions for
  developing a plan
- It can be used via `claude -p` to develop a plan file
- Feedback `>` annotations are integrated and removed;
  legitimate markdown quotes are left alone
- Unanswerable gaps produce specific `>` questions in Open
  questions (at top of document, omitted if none)
- A plan with all criteria met transitions to `ready`
- fieldstones.org is updated when design thinking emerges
