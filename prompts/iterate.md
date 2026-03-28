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

### 2. Check for feedback annotations and open questions

Scan the plan file for:

- **Feedback annotations** - a `>` quoted passage from the plan
  followed by a direct response (unquoted text). These are the
  human's answers to open questions or comments on the plan.
- **Open questions awaiting response** - `>` quoted questions in
  the Open questions section with no unquoted response below them.
  The human has not yet answered these.

### 3. Decide the next action

Apply the first matching rule:

1. **Feedback annotations exist** - the human has responded to
   open questions or commented on the plan. The plan needs
   revision to integrate this feedback, even if status is
   `feedback`.
   Output: `%iterate%:plan`

2. **Status is `feedback`** - a prompt set `feedback` because it
   needs human input, and no feedback annotations have been
   provided yet. Wait for the human.
   Output: `%iterate%:feedback`

3. **Status is `draft`** - the plan needs more development before
   it can be implemented.
   Output: `%iterate%:plan`

4. **Status is `ready` or `active`, uncompleted tasks remain** -
   the plan is ready and has work to do.
   Output: `%iterate%:implement`

5. **All tasks are completed** - every task checkbox is checked.
   Output: `%iterate%:done`

The rules are ordered by priority. Feedback annotations take
precedence over everything - the human has spoken and the plan
must adapt. A `feedback` status without annotations means the
loop must wait. A draft plan needs development regardless of task
state.

This prompt is a pure router - it reads state but never writes it.
Each step prompt owns its own state transitions (plan.md sets
`draft`/`ready`/`feedback`, implement.md sets
`active`/`done`/`feedback`). This keeps iterate idempotent: you
can run it multiple times and it just re-reads and re-decides.

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
