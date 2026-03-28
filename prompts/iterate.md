# Iterate on a plan

You are driving the full cycle for a plan file: develop it, implement
it, collect feedback, and finish. Your job is to read the plan's
current state and decide what happens next. You output exactly one
action line per invocation.

## Input

You receive a plan file (markdown with YAML frontmatter).

## What you do

### 1. Read the plan

Read the plan file. Note the frontmatter status and the contents.

### 2. Check for open questions

Look for an **Open questions** section. If it exists and contains
any `>` quoted questions that have not been answered (no response
text below the quote), the plan needs human input before it can
proceed.

### 3. Decide the next action

Apply the first matching rule:

1. **Open questions exist** - unanswered questions in the Open
   questions section need human input.
   Output: `%iterate%:feedback`

2. **Status is `draft`** - the plan needs more development before
   it can be implemented.
   Output: `%iterate%:plan`

3. **Status is `ready` or `active`, uncompleted tasks remain** -
   the plan is ready and has work to do.
   Output: `%iterate%:implement`

4. **All tasks are completed** - every task checkbox is checked.
   Output: `%iterate%:done`

The rules are ordered by priority. Open questions take precedence
over everything else. A draft plan needs development regardless of
task state.

This prompt is a pure router - it reads state but never writes it.
Each step prompt owns its own state transitions (plan.md sets
`draft`/`ready`, implement.md sets `active`/`done`). This keeps
iterate idempotent: you can run it multiple times and it just
re-reads and re-decides. If implementation flags divergence, the
implement prompt sets the plan back to `draft` and rule 2 handles
it naturally on the next iteration.

### 4. Output the action

Write exactly one line in your response in this format:

```
%iterate%:<action>
```

Where `<action>` is one of: `plan`, `implement`, `feedback`, `done`.

Briefly explain why you chose this action (one or two sentences),
then output the action line.

## Rules

- **One action per invocation.** Read the plan, decide, output
  the action line, stop.
- **Exactly one action line.** Your response must contain exactly
  one `%iterate%:<action>` line. No more, no less.
- **Do not modify the plan.** You are a router, not an editor.
  Other prompts handle plan changes and implementation.
- **Do not implement.** Your only job is to decide what happens
  next. The caller dispatches to the appropriate prompt.
- **First match wins.** Apply the decision rules in order and
  take the first one that matches.
