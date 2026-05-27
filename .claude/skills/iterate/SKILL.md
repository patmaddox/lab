---
description: >
  Move work forward. Reads commit messages, assesses the state of
  the work, and dispatches to the best skill - or accepts an
  explicit skill hint to skip the heuristic.
  TRIGGER when the user says /iterate.
user-invocable: true
argument-hint: "[skill] [revset] [file.org]"
allowed-tools: Read, Edit, Write, Bash, Grep, Glob, WebFetch, WebSearch, Agent, Skill
---

# iterate

Assess the current state of work and dispatch to the skill that
best advances it. A single entry point for "move this forward."

## Input

`$ARGUMENTS` may contain a skill hint, revsets, and filenames in
any order. The skill classifies each argument:

- Arguments with a file extension (e.g. `foo.org`, `notes.md`) are
  **filenames**
- Arguments matching a known skill name (visible in the skill list
  loaded into context) are a **skill hint**
- Everything else is a **revset**

At most one skill hint is expected. If multiple skill names appear,
use the first and treat the rest as revsets.

## With a skill hint

When a skill hint is present (e.g. `/iterate plan foo.org`), invoke
that skill immediately via the Skill tool, passing the remaining
arguments (revsets and filenames) as the skill's arguments. No
commit message reading or heuristic needed.

This gives the user an explicit "I know what I want" mode while
still going through iterate as the entry point.

## Without a skill hint

When no skill hint is given, perform gap analysis and then route:

1. **Read commit messages** from `mutable() & ::@` (or
   `mutable() & ::<revset>` if a revset argument was given),
   ordered chronologically:
   ```
   jj log -r 'mutable() & ::<revset>' --no-graph -T 'description ++ "\n---\n"' --reversed
   ```

2. **Examine the working copy** - check what files exist, what has
   been modified, and what types of files are involved:
   ```
   jj diff -r 'mutable() & ::<revset>' --no-pager --git -s
   ```

3. **Call the gap-analysis skill** via the Skill tool, passing
   revset and filename arguments. The skill writes an org document
   describing the gap between commit messages and current state.

4. **Read the gap analysis document** and determine routing. Use
   the skill descriptions already loaded in context as the routing
   table. Consider:
   - What the gap analysis says is missing or different
   - Which skill's description best matches closing those gaps
   - Whether the gap analysis includes a `* Questions for user`
     section indicating severe ambiguity

   If iterate cannot determine which skill to dispatch (the gap
   analysis has questions that make routing a coin flip), stop and
   tell the user to review the gap analysis document. Do not
   dispatch.

5. **Invoke the chosen skill** via the Skill tool, passing through
   the revset and filename arguments along with the gap analysis
   as additional context.

## Single-turn contract

Iterate runs gap analysis and then dispatches to exactly one
routing skill per invocation, then returns. It never loops or
sequences multiple routing skills. The caller - whether a user
at the keyboard or an automation script - owns the loop and
decides when to call iterate again.

## Routing guidance

The dispatch decision is a judgment call, not a lookup table. Some
signals to weigh:

- Commit messages describing what to build or how to approach
  something suggest planning work
- Commit messages asking to investigate or learn about a topic
  suggest research work
- An existing plan document with CR blocks suggests the plan needs
  updating
- An existing research document with CR blocks suggests the
  research needs updating
- The presence or absence of code changes, org files, and other
  artifacts all inform the decision

The state of existing artifacts is often a stronger signal than
commit message content alone. A commit describing a feature to
build means different things depending on what exists:

- No plan document exists yet: plan first
- A plan exists with CR blocks: the plan needs updating
- A plan exists and is stable: the next skill depends on what
  the plan calls for
- Research document with CR blocks: research needs updating
- Code exists but tests fail or style issues present:
  the relevant fix skill

Do not enumerate every possible skill or maintain a hardcoded
routing table. The skill descriptions in context are the routing
table.

## No commit

Do not commit when done. The dispatched skill handles its own
output conventions.
