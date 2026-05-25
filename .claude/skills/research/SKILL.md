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

The document has two sections separated by an HTML comment marker:

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

## Response structure

The research response has two parts, in this order:

### 1. Questions (optional)

If clarification would help refine the research, place questions
at the very top in email blockquote format. Questions do not block
the research - always provide the best possible response with what
you know, and note any assumptions you made. The questions are
there to help the user provide detail that improves the next run.

```
> What version of FreeBSD are you targeting?
> Is this for a jail or the host system?
```

When the user answers (by writing responses under the quotes),
incorporate their answers into the research on the next run,
remove the answered questions, and refine any assumptions.

### 2. Research findings

Clear, concise findings organized for the topic at hand. This is
not an append-only log - it should always represent the best
current understanding. Structure it however best fits the topic
(prose, sections, bullet points, comparison tables, etc.).

Cite sources when possible. Distinguish between what documentation
says and what community experience suggests.

## Re-run behavior

Each run produces a fresh response that:

- Incorporates any changes the user made to their content above
  the marker
- Incorporates any answers the user wrote to previous questions
- Reflects the latest research (not cached from prior runs)
- Removes questions that have been answered
- May restructure entirely if the user's content has evolved

## Research approach

- Use web search and web fetch to find current, authoritative
  information
- Prefer primary sources (official docs, RFCs, source code) over
  secondary summaries
- When sources conflict, note the conflict and explain which
  source to trust and why
- Be honest about confidence levels and gaps in available
  information
