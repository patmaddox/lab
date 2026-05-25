---
description: >
  Turn commit messages into a plan. Reads a jj revset, treats the
  commit messages as a prompt, and writes an org-mode plan to
  doc/plans/<branch-name>.org.
  TRIGGER when the user says /iterate.
user-invocable: true
argument-hint: "<revset>"
allowed-tools: Read, Edit, Write, Bash, Grep, Glob, WebFetch, WebSearch, Agent
---

# iterate

Read commit messages from a jj revset and produce an org-mode plan.

## Input

`$ARGUMENTS` is a jj revset (e.g. `@`, `claude/iterate-skill`,
`abc123..xyz456`). If `$ARGUMENTS` is empty, default to `@`.

## Validation

1. Check that the head revision is not trunk:
   ```
   jj log -r 'heads($ARGUMENTS) & trunk()' --no-graph -T 'change_id'
   ```
   If this produces output, **stop with an error**:
   ```
   Error: refusing to iterate on the trunk commit.
   ```

2. Verify the revset has exactly one head:
   ```
   jj log -r 'heads($ARGUMENTS)' --no-graph -T 'change_id ++ "\n"'
   ```
   If this produces more than one line, **stop with an error**:
   ```
   Error: revset has multiple heads. The iterate skill requires
   a revset with exactly one head revision.
   ```

3. Read the bookmark name from the head revision:
   ```
   jj log -r 'heads($ARGUMENTS)' --no-graph -T 'bookmarks'
   ```
   - If no output, **stop with an error**:
     ```
     Error: head of revset has no bookmark. The iterate skill
     requires exactly one bookmark on the head revision.
     ```
   - If multiple bookmarks (space-separated), **stop with an error**:
     ```
     Error: head revision has multiple bookmarks. The iterate
     skill requires exactly one bookmark on the head revision.
     ```

4. Derive the output filename from the bookmark by replacing `/`
   with `--`. Example: `claude/iterate-skill` becomes
   `claude--iterate-skill.org`.

## Reading commit messages

Read all commit messages in the revset, ordered chronologically
(oldest first):

```
jj log -r "$ARGUMENTS" --no-graph -T 'description ++ "\n---\n"' --reversed
```

Treat the messages as a sequential prompt. Later commits may refine
or override earlier ones - use judgment based on the actual content
and sequence.

## Updating commit messages

Never modify or lose any text the user wrote in a commit message.
If the skill needs to annotate a commit (e.g. to record status or
model notes), append a `--- model ---` block at the end:

```
user's original message here

--- model ---
Model notes go here.
```

Everything above the `--- model ---` separator is untouchable.
Everything below it can be freely rewritten on subsequent runs.

## Output

Write the plan to `$(jj root)/doc/plans/<filename>.org`, creating
the `doc/plans/` directory if it does not exist.

The plan structure is fully adaptive - organize however best fits
the task described in the commit messages. Use org-mode headings,
lists, and prose as appropriate. There are no required headings
for the plan content itself.

The title and plan headings are completely rewritten on each run.
The questions heading persists open threads (see below).

## Document structure

The file uses multiple top-level headings:

```org
* <title>
Summary of what this plan covers.
* questions for user
** TODO What is the intended deployment target?
** TODO Should this support multiple backends?
* First section of the plan
...
* Second section of the plan
...
```

Never insert blank lines before or after headings.

### Title heading (always first)

The first heading is the plan title with a brief summary
paragraph underneath. This is rewritten on each run.

### Questions heading (optional, always second if present)

```org
* questions for user
** TODO What is the intended deployment target?
** TODO Should this support multiple backends?
```

Each question is a separate `TODO` sub-heading. Questions do not
block the plan - always provide the best possible plan with what
you know.

On each re-run, incorporate responses from all answered questions
into the plan. Only remove questions the user has marked DONE -
these are fully resolved. Questions still marked TODO that have
responses underneath should be kept in place so the user can
continue refining them. If all questions are DONE, remove the
entire questions heading.

### Threaded question replies

Follow the same threading conventions as the research skill.
When the user answers a question inline but leaves it in TODO
state, it means they consider it an open loop. Respond with
another level of nesting, continuing the conversation.

The user replies by placing a CR block after the content they
want to respond to. The user never types `>` directly - all
`>` indentation and `%` headers are written by the model.

See the research skill for full threading rules and examples.

### Plan headings

The remaining top-level headings contain the plan itself.
Structure with as many top-level headings and sub-headings as
appropriate for the task. These are all rewritten on each run.

## Inline replies (CR blocks)

The user may reply inline to plan sections using CR blocks. A
CR block is placed after the content the user wants to comment
on:

```org
* Implementation approach
Proceed in three phases: setup, migration, validation.
#+BEGIN_CR
Skip the migration phase, we're starting fresh.
#+END_CR
```

CR blocks are valid only inside plan headings (everything after
the title and questions headings) and `* questions for user`
sub-headings.

On re-run, the skill reads each CR block as feedback on the
preceding content, incorporates it into the plan, and removes
the block. CR blocks are not patch instructions - they are new
information to integrate into the document. The plan headings
are rewritten from scratch.

## No commit

Do not commit when done. The plan file is written into the current
working copy, which is already an in-progress commit.
