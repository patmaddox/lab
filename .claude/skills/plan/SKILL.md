---
description: >
  Produce an org-mode plan from commit messages. Reads a jj revset,
  treats the commit messages as a prompt, and writes a structured
  plan with questions and inline reply support.
  TRIGGER when the user says /plan.
user-invocable: true
argument-hint: "[revset] [file.org]"
allowed-tools: Read, Edit, Write, Bash, Grep, Glob, WebFetch, WebSearch, Agent
---

# plan

Read commit messages from a jj revset and produce an org-mode plan.

## Input

`$ARGUMENTS` may contain revsets and filenames in any order. The
skill classifies each argument:

- Arguments with a file extension (e.g. `foo.org`, `notes.md`) are
  treated as **filenames**
- Everything else is treated as a **revset**

If no revset argument is found, default to `@`. Multiple revset
arguments are joined as a single revset expression.

File arguments become candidates for the output filename. The
extension heuristic is a first pass - if a file argument does not
exist on disk when the skill tries to read or write it, that
naturally surfaces the misclassification.

## Filename derivation

The skill considers three sources of candidates for the output
file and picks the best one holistically - not as an ordered
preference.

### Explicit file arguments

Any filenames passed in `$ARGUMENTS` are candidates. These are a
strong signal of user intent.

### Existing mutable files

Check what files have been modified in `mutable() & ::<revset>`
commits - this represents the work in progress on the branch:

```
jj diff -r 'mutable() & ::<revset>' --no-pager --git -s
```

Any file type counts, though `.org` files are the strongest
candidates. Files whose name relates to the commit subject are
stronger signals than unrelated files. Other modified files
(`.md`, etc.) are weaker but still relevant signals.

### Commit subject slug

Derive a slug from the commit message subject line of the head
revision: lowercase, spaces to hyphens, strip the `<area>: `
prefix and non-alphanumeric characters besides hyphens. Use this
to generate a candidate path like `<slug>.org` at the repo root.

### Selection logic

Evaluate all candidates together and pick the best one. Factors
to weigh:

- An explicitly passed filename is a strong signal of intent
- A mutable file whose name relates to the commit subject is a
  strong signal of continuity
- A generated slug is the fallback when nothing better exists
- If multiple signals converge on the same file, that reinforces
  the choice

## Reading commit messages

Read all commit messages in `mutable() & ::<revset>`, ordered
chronologically (oldest first). This captures the full branch
context, not just the given revset:

```
jj log -r 'mutable() & ::<revset>' --no-graph -T 'description ++ "\n---\n"' --reversed
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

Write the plan to the file selected by the filename derivation
logic, creating parent directories as needed.

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
