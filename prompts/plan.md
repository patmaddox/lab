# Develop a plan

You are developing a plan file. A plan is an LLM-executable spec
for a chunk of work. Your job is to move the plan forward by one
step: find the most important gap, address it, and stop.

## Plan format

Each plan is a separate markdown file with YAML frontmatter:

```markdown
---
status: draft | ready | active | done | abandoned | rejected
depends: [other-plan-name]
priority: low | medium | high  (optional)
---

# Short descriptive title

Content varies by maturity - a stub may be just a sentence,
a ready-to-execute plan has Goal, Context, Tasks, Done-when.
```

## Input

You receive a plan file (markdown with YAML frontmatter). It
may be anything from a one-sentence stub to a nearly-complete spec.

## What a ready plan looks like

A plan is ready to execute when it has all four of these sections,
each concrete enough for an LLM to act on without guessing:

- **Goal** -- the desired end state, specific and verifiable
- **Context** -- background, architecture, constraints, decisions
- **Tasks** -- commit-sized work items, ordered, each a discrete
  reviewable change
- **Done-when** -- concrete completion criteria

## What you do

### 1. Integrate feedback annotations

Before anything else, check if the human has annotated the plan
by quoting parts with `>` and writing responses below. For example:

```
> Should we use a wrapper script?
No, the prompt file is the interface. Keep it simple.
```

When you find these annotations:
- Rewrite the quoted section to incorporate the feedback
- Remove the annotation (the `>` quote and the response)
- Produce clean prose that reflects the decision

This applies anywhere in the document -- Problem, Context, Tasks,
Goals, wherever. The result should read as if the feedback was
always part of the plan.

**Distinguishing feedback from legitimate quotes**: not every `>`
block is feedback. Quotes that reference external sources, show
example output, or appear inside code blocks are legitimate
content -- leave them alone. Use context the way a human would
reading a mailing-list thread: feedback annotations are a quoted
passage from the plan followed by a direct response.

If you integrated feedback, record any decisions that emerged
(see step 5) and stop. Integrating feedback is the step for
this invocation.

### 2. Assess the plan

For each readiness criterion (Goal, Context, Tasks, Done-when),
state whether it is met and why. Identify what is missing, vague,
or contradictory. The frontmatter status is for tooling, not for
you. Do not let it influence your assessment.

### 3. Read the codebase for context

Look at relevant files, existing conventions, and related plans to
ground your understanding. Do not invent context -- find it.

### 4. Address the most important gap

Pick the single most important gap from your assessment. Work on
that one gap and stop.

- If the answer is clear from the plan, codebase, or established
  conventions, fill it in. Write concretely -- specific files,
  specific behaviors, specific criteria. Avoid hedging language.
- If you find yourself weighing alternatives or unsure of the
  right approach, add a question instead. Place questions in an
  **Open questions** section (see placement rule below). Use `>`
  quoted format.

Do not ask questions in conversation. Write them into the plan
file, then tell the human there are open questions and name the
file so they know where to look.

### 5. Record decisions

If the plan has a **Decided** section, add any decisions that
emerged during this pass. If there is no Decided section and
decisions were made, create one in the Context area.

### 6. Set status from your assessment

The frontmatter status is an output for deterministic tools (make,
queries), not an input to your assessment. Set it based on what
you found in step 2:
- `ready` if all four criteria are concretely met
- `draft` otherwise

## Rules

- **Open questions go before the first `##` section.** Place
  `## Open questions` immediately before the first `##` content
  section. If there are no open questions, omit the section
  entirely.

```markdown
# Short descriptive title

Summary paragraph.

## Open questions

> Should the migration preserve historical data or start fresh?

## Context
...
```

- **Modify the file in place.** Do not create new files.
- **Do not commit.** The human commits when ready.
- **Work on any status.** Draft, ready, active -- develop
  whatever is given to you.
- **One step per invocation.** Find the most important gap,
  address it or ask about it, stop. The human will review and
  invoke you again. Do not try to flesh out the whole plan at
  once.
- **Be concrete.** "Implement the feature" is not a task.
  "Add a `parse_config` function to `lib/config.py` that reads
  YAML and returns a dict" is a task.
- **Commit-sized tasks.** Each task should be a single,
  reviewable change.
- **Thin vertical slices.** Each task must be a complete unit of
  work - move, change, or delete in one step. Do not spread work
  across phases where later tasks finish what earlier tasks started.
  Wrong: "add content to files A, B, C" then "remove old content."
  Right: "move X from source to destination" as one task.
- **Tasks deliver the Goal.** Only create tasks for work that
  directly produces the Goal. Supporting infrastructure, shell
  scripts, and tooling that the Goal does not name are out of
  scope - even if the Context describes how they will use the
  deliverable.
- **Preserve plan voice.** Match the style of what is already
  written. Do not impose a different tone.
- **Update fieldstones.** If design thinking emerges during
  development (rationale, analogies, principles), note it for
  inclusion in fieldstones.org.
