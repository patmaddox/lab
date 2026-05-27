---
description: >
  Analyze the gap between commit message descriptions and current
  codebase state. Produces an org document describing what exists,
  what is missing, and what differs.
  TRIGGER when the user says /gap-analysis.
user-invocable: true
argument-hint: "[revset] [file.org]"
allowed-tools: Read, Edit, Write, Bash, Grep, Glob, Agent
---

# gap-analysis

Analyze the gap between the state described in commit messages and
the actual state of the working copy and codebase. Always produces
an org document as output.

## Input

Takes commit messages and working copy state. These are typically
provided by iterate, but the skill can also be invoked standalone.

When invoked standalone, read inputs the same way iterate does:

1. Read commit messages from `mutable() & ::@` (or
   `mutable() & ::<revset>` if a revset argument was given):
   ```
   jj log -r 'mutable() & ::<revset>' --no-graph -T 'description ++ "\n---\n"' --reversed
   ```

2. Read working copy file summary:
   ```
   jj diff -r 'mutable() & ::<revset>' --no-pager --git -s
   ```

When invoked by iterate, these inputs are already gathered and
available in context.

## Analysis

Read the commit messages to understand the described end state.
Examine the working copy and codebase to understand what currently
exists. Compare the two.

Read files as needed to verify whether described capabilities
actually exist. Do not rely solely on file names or diff summaries
- open files and check their content when the commit messages
describe specific behavior or structure.

## Output

Write an org file containing:

- `* Described state` - what the commit messages describe as the
  end state, in concrete terms
- `* Current state` - what currently exists in the working copy
  and codebase relevant to the described state
- `* Gaps` - what is missing or differs from the described state.
  Each gap is a sub-heading with enough detail for a skill to act
  on it
- `* Assumptions` - where things were unclear, note what was
  assumed and why ("assuming X means Y because Z")
- `* Questions for user` - only when ambiguity is severe enough
  that routing would be a coin flip. Each question is a TODO
  sub-heading. Most ambiguities should be noted as assumptions
  and passed through.

The threshold for adding questions is high. The analysis should
almost always be complete enough for iterate to route without
user intervention.

If a filename argument was provided, write to that file. Otherwise
derive the filename from the current working copy's short change ID:
`gap-analysis-<change_id>.org` in the repo root. Get the change ID
with:
```
jj log -r @ --no-graph -T 'change_id.short()'
```

## No commit

Do not commit when done. The caller handles commits.
