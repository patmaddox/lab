# Develop a plan

You are developing a plan file. A plan is an LLM-executable spec
for a chunk of work. Your job is to make one pass over the plan:
fill in what you can, ask questions about what you can't, and
leave the file in better shape than you found it.

## Input

You receive a plan file (markdown with optional YAML frontmatter). It
may be anything from a one-sentence stub to a nearly-complete spec.

## What a ready plan looks like

A plan is ready to execute when it has all four of these sections,
each concrete enough for an LLM to act on without guessing:

- **Goal** -- the desired end state, specific and verifiable
- **Context** -- background, architecture, constraints, decisions
- **Tasks** -- commit-sized work items, ordered, each a discrete
  reviewable change
- **Done-when** -- concrete completion criteria

## What you do on each pass

### 1. Read the plan and assess it

Identify what is missing, vague, or contradictory. Compare against
the readiness criteria above.

### 2. Read the codebase for context

Look at relevant files, existing conventions, and related plans to
ground your understanding. Do not invent context -- find it.

### 3. Integrate feedback annotations

The human may have annotated the plan by quoting parts with `>`
and writing responses below. For example:

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

### 4. Fill in detail or ask questions

For each gap you identified in step 1, decide: do you have enough
information to fill it in, or do you need to ask?

- If the answer is clear from the plan, codebase, or established
  conventions, fill it in. Write concretely -- specific files,
  specific behaviors, specific criteria. Avoid hedging language.
- If you find yourself weighing alternatives or unsure of the
  right approach, add a question instead. Place questions in an
  **Open questions** section at the top of the document, directly
  after the title and summary paragraph, before the Problem
  section. Use `>` quoted format:

```markdown
## Open questions

> Should the migration preserve historical data or start fresh?

> What is the expected latency budget for this endpoint?
```

If there are no open questions, omit the section entirely.

### 5. Record decisions

If the plan has a **Decided** section, add any decisions that
emerged during this pass. If there is no Decided section and
decisions were made, create one in the Context area.

### 6. Assess readiness and update status

Assess the plan against the readiness criteria regardless of its
current status. A plan marked `ready` may have gained new criteria,
or its details may have drifted out of date -- the frontmatter
status is for querying, not for determining whether work remains.

If the plan meets all readiness criteria (Goal, Context, Tasks,
Done-when -- all concrete enough to execute), set status to `ready`.
If it does not, set status to `draft` even if it was previously
`ready`.

## Rules

- **Modify the file in place.** Do not create new files.
- **Do not commit.** The human commits when ready.
- **Work on any status.** Draft, ready, active -- develop
  whatever is given to you.
- **One pass per invocation.** Fill in what you can, ask what
  you cannot, stop. The human will answer questions and invoke
  you again.
- **Be concrete.** "Implement the feature" is not a task.
  "Add a `parse_config` function to `lib/config.py` that reads
  YAML and returns a dict" is a task.
- **Commit-sized tasks.** Each task should be a single,
  reviewable change.
- **Preserve plan voice.** Match the style of what is already
  written. Do not impose a different tone.
- **Update fieldstones.** If design thinking emerges during
  development (rationale, analogies, principles), note it for
  inclusion in fieldstones.org.
