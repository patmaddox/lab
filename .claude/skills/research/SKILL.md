---
description: >
  Research a topic based on the user's document. Reads the document,
  researches thoroughly, and writes findings below a marker line.
  TRIGGER when the user says /research or asks to research a document.
user-invocable: true
argument-hint: "<file>"
allowed-tools: Read, Edit, Write, Bash, Grep, Glob, WebFetch, WebSearch, Agent
---

# research

Research the topic described in a user's document and write findings
back into the same file.

## Input

`$ARGUMENTS` is a path to the document. Read it first.

## Document format

The format depends on the file type.

### Markdown files (.md)

Two sections separated by an HTML comment marker:

```
(user's content - notes, questions, thinking)

<!-- research -->

(research response - written by this skill)
```

Everything **above** `<!-- research -->` is the user's content.
**Never modify anything above the marker.** Not a word, not
whitespace, not punctuation.

Everything **below** `<!-- research -->` is the research response.
This section gets completely rewritten on each run.

If the marker does not exist yet, append it (with a blank line
before it) and then write the response below.

#### Questions (optional, markdown)

If clarification would help refine the research, place questions
at the very top of the research response in email blockquote
format. Questions do not block the research - always provide the
best possible response with what you know, and note any
assumptions you made.

```
> What version of FreeBSD are you targeting?
> Is this for a jail or the host system?
```

When the user answers (by writing responses under the quotes),
incorporate their answers into the research on the next run,
remove the answered questions, and refine any assumptions.

#### Findings (markdown)

Clear, concise findings below the questions. This is not an
append-only log - it should always represent the best current
understanding.

### Org files (.org)

The user's content is everything that exists before the
skill-managed headings. **Never modify the user's content.**

The skill appends two top-level headings at the bottom of the
file. Both are completely rewritten on each run.

#### Questions heading (optional, org)

```org
* TODO questions for user
** TODO What version of FreeBSD are you targeting?
** TODO Is this for a jail or the host system?
```

Each question is a separate `TODO` sub-heading under the
`* TODO questions for user` heading. Questions do not block the
research - always provide the best possible response with what
you know.

On each re-run, incorporate responses from all answered questions
into the research. Only remove questions the user has marked
DONE - these are fully resolved. Questions still marked TODO
that have responses underneath should be kept in place so the
user can continue refining them. If all questions are DONE,
remove the entire questions heading.

#### Research heading (org)

```org
* research
```

Research findings go under this heading. Structure the content
with org sub-headings, lists, or prose as appropriate.

This heading always comes **after** the questions heading (if
present).

### Common rules for both formats

Findings should be clear and concise, organized for the topic at
hand. Structure however best fits (prose, sections, bullet points,
comparison tables, etc.).

Cite sources when possible. Distinguish between what documentation
says and what community experience suggests.

## Re-run behavior

Each run produces a fresh response that:

- Incorporates any changes the user made to their content (above
  the marker in markdown, or before the skill headings in org)
- Incorporates any answers the user wrote to previous questions
- Reflects the latest research (not cached from prior runs)
- Removes questions that have been answered
- May restructure entirely if the user's content has evolved

## Local references

The user's document may reference local files in this repo (notes,
config files, examples, etc.). These represent the user's current
understanding. Read all referenced files before researching.

Local refs are **not** a source of truth - they are claims to
verify. The research goal is to find where the user's
understanding is wrong, outdated, or incomplete.

## Research approach

- Use web search and web fetch to find current, authoritative
  information
- Prefer primary sources (official docs, RFCs, source code) over
  secondary summaries
- When sources conflict, note the conflict and explain which
  source to trust and why
- Be honest about confidence levels and gaps in available
  information

### Validation focus

The primary role of this skill is to expose flaws or gaps in the
user's knowledge. For every claim or assumption found in the
user's content and local refs:

1. **Attempt to disprove it.** Search for counterexamples,
   corrections, version-specific changes, or deprecations.
2. **Identify gaps.** Note important aspects of the topic that
   the user has not addressed at all.
3. **Skip what's already correct.** Do not repeat information
   that is clearly and accurately stated in the user's
   references. The user already knows it.

If all information in the user's content and references is
accurate, current, and complete, the research response should
simply state:

```
Information is accurate, current, and complete. Nothing to report.
```

The goal is a focused analysis the user can read, understand, and
integrate into their own knowledge - not a comprehensive survey
of the topic.
