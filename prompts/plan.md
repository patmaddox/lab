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

## Lifecycle

Plans are a corpus at varying levels of detail, not an ordered
backlog. A plan starts as a stub and gets fleshed out when ready
to work on. Status tracks the lifecycle:

- **draft**: idea captured, not yet detailed enough to execute
- **ready**: plan is clear and ready to be picked up
- **active**: currently being worked on
- **done/abandoned/rejected**: move to `plans/archive/` and add
  a Postmortem section

Active plans (draft, ready, active) stay in `plans/`.
Completed plans move to `plans/archive/`.

### INDEX.md

Run `make` in the plans/ directory to regenerate `INDEX.md` from
frontmatter. INDEX.md is generated - do not edit it by hand.

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

### 1. Respond to feedback annotations

Before anything else, check if the human has annotated the plan
by quoting parts with `>` and writing responses below. For example:

```
> Should we use a wrapper script?
No, the prompt file is the interface. Keep it simple.
```

Annotations come in two forms - directives and questions.

**Directives** tell you what to do:

```
> Should we use a wrapper script?
No, the prompt file is the interface. Keep it simple.
```

When you find directives:
- Rewrite the quoted section to incorporate the feedback
- Remove the annotation (the `>` quote and the response)
- Produce clean prose that reflects the decision

**Questions** ask you to find out or figure out something:

```
> We'll store config in SQLite.
Does SQLite handle concurrent writes from multiple processes?
```

When you find questions:
- Research the answer - read code, check docs, reason it through
- Move the question and your response to a `## Research` section.
  Double-quote the human's question and single-quote your response
  so the entire exchange is quoted:

```
>> We'll store config in SQLite.
>> Does SQLite handle concurrent writes from multiple processes?
>
> SQLite uses file-level locking. Concurrent reads are fine, but
> concurrent writes serialize behind a lock. With WAL mode, writers
> do not block readers. For this use case (infrequent config writes,
> frequent reads) it handles concurrency well.
```

- If you cannot answer confidently, say what you found and what
  remains unclear. A partial answer is still useful.

Research items block progress just like open questions - the human
needs the information before they can give a directive. On the
next pass the human may accept the research and provide a
directive, ask a follow-up, or redirect.

Both forms apply anywhere in the document - Problem, Context,
Tasks, Goals, wherever. For directives, the result should read
as if the feedback was always part of the plan.

**Distinguishing feedback from legitimate quotes**: not every `>`
block is feedback. Quotes that reference external sources, show
example output, or appear inside code blocks are legitimate
content - leave them alone. Use context the way a human would
reading a mailing-list thread: feedback annotations are a quoted
passage from the plan followed by a direct response.

If you processed annotations, record any decisions that emerged
(see step 5) and stop. Responding to annotations is the step
for this invocation.

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
- If you chose between alternatives while writing, that is
  uncertainty -- add it as an open question instead of deciding
  and hedging in conversation afterward.
- If you find yourself weighing alternatives or unsure of the
  right approach, add a question instead. Place questions in an
  **Open questions** section (see placement rule below). Use `>`
  quoted format. Below the question, still within the `>` block,
  provide a concise analysis: describe the possible approaches,
  note the pros and cons of each, and offer a recommendation.
  Be clear about the strength of the recommendation - if there
  is no clear winner, say so and leave the decision to the human.
  Keeping the entire analysis in `>` blocks separates LLM text
  from human responses.

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
- `ready` if all four criteria are concretely met and no tasks
  have started
- `active` if tasks exist and some are complete but work remains
- `feedback` if you added open questions or research that block progress
- `draft` otherwise

## Rules

- **Open questions and Research go before the first content
  section.** Place `## Open questions` and `## Research`
  immediately before the first `##` content section, in that
  order. Omit either section if it has no entries.

```markdown
# Short descriptive title

Summary paragraph.

## Open questions

> Should the migration preserve historical data or start fresh?
>
> **Preserve history**: Keeps audit trail, no data loss.
> Downside: complex migration, schema mapping may be lossy.
>
> **Start fresh**: Simpler migration, clean schema.
> Downside: loses historical context, may need parallel access
> to old system during transition.
>
> No clear recommendation - depends on compliance requirements
> and how often historical data is actually queried.

## Research

>> We'll store config in SQLite.
>> Does SQLite handle concurrent writes from multiple processes?
>
> SQLite uses file-level locking. Concurrent reads are fine,
> but concurrent writes serialize behind a lock. With WAL mode,
> writers do not block readers.

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

## Relationship to other docs

- **README.md / DESIGN.md**: durable, human-readable docs about
  architecture and design. Plans reference these for context.
  Plans produce updates to these docs as part of their work.
- **fieldstones.org**: design rationale and thinking. Plans may
  generate new fieldstones during execution.
- **CLAUDE.md**: directives for LLM behavior. Plans may produce
  updates to CLAUDE.md when new conventions are established.
