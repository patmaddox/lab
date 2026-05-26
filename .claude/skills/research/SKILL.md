---
description: >
  Research a topic based on the user's org-mode document. Reads the
  document, researches thoroughly, and writes findings below the
  user's content.
  TRIGGER when the user says /research or asks to research a document.
user-invocable: true
argument-hint: "[file.org] [revset]"
allowed-tools: Read, Edit, Write, Bash, Grep, Glob, WebFetch, WebSearch, Agent
---

# research

Research the topic described in a user's org-mode document and write
findings back into the same file.

## Input

`$ARGUMENTS` may contain a filename and a revset in any order.
The skill classifies each argument:

- An argument with a file extension (e.g. `foo.org`) is the
  **filename**
- Everything else is a **revset**

If no revset is given, default to `@`. The revset must resolve to
a single commit.

## File resolution

The skill resolves which .org file to operate on:

### Explicit file given

Read it directly and proceed to researching.

### No file given

The skill considers candidates holistically, not as an ordered
preference:

- **Existing mutable files**: check what files have been modified
  in `mutable() & ::<revset>` commits:
  ```
  jj diff -r 'mutable() & ::<revset>' --no-pager --git -s
  ```
  Any `doc/llm-research/*.org` file is a strong candidate.
- **Commit subject slug**: derive a slug from the commit message
  subject line (lowercase, spaces to hyphens, strip the
  `<area>: ` prefix and non-alphanumeric characters besides
  hyphens). Use this to generate a candidate path like
  `doc/llm-research/<slug>.org`.

If an existing mutable file is found whose name relates to the
commit subject, use it. Otherwise create the slug-derived path
as a new research document.

## New file creation

When creating a new research file:

1. Read the commit message:
   ```
   jj log -r <revset> --no-graph -T 'description'
   ```
2. Extract the body (everything after the subject line). If a
   `--- model ---` separator exists, only take the user-authored
   text above it - discard the model block.
3. Write the body as user content at the top of the new .org file,
   formatted the same as any research document's user section
   (the subject line becomes the first org heading, stripping the
   `llm-research: ` area prefix if present).
4. Delete the body from the commit message using `jj describe`,
   leaving only the subject line.
5. Proceed with research against the newly created document.

## Commit message conventions

The skill uses the `--- model ---` separator for any commit message
text it writes. Everything above the separator is user-authored and
untouchable. Everything below can be freely rewritten on subsequent
runs.

After completing research, write a concise summary of the key
findings into the commit message as a model block using
`jj describe`:

```
user's original subject

--- model ---
Key findings summary here.
```

If the user wrote a body, preserve it above the separator:

```
user's original subject

user's original body

--- model ---
Key findings summary here.
```

Never modify or lose any text the user wrote above the separator.

## No commit

Do not commit when done. The research file is written into the
current working copy, which is already an in-progress commit.

## Document structure

The user's content is everything that exists before the
skill-managed headings. **Never modify the user's content.**

The skill manages two top-level headings at the bottom of the
file. Both are completely rewritten on each run.

### Questions heading (optional)

```org
* questions for user
** TODO What version of FreeBSD are you targeting?
** TODO Is this for a jail or the host system?
```

Each question is a separate `TODO` sub-heading under the
`* questions for user` heading. Questions do not block the
research - always provide the best possible response with what
you know.

On each re-run, incorporate responses from all answered questions
into the research. Only remove questions the user has marked
DONE - these are fully resolved. Questions still marked TODO
that have responses underneath should be kept in place so the
user can continue refining them. If all questions are DONE,
remove the entire questions heading.

### Threaded question replies

When the user answers a question inline but leaves it in TODO
state, it means they consider it an open loop - they have likely
asked a follow-up question. Respond with another level of
nesting, continuing the conversation.

The quoting depth increases with each exchange. Add attribution
headers using `%` instead of `>` (e.g. `%% model wrote:`,
`% user wrote:`) to clarify who said what at each level. The
`%` prefix distinguishes headers from quoted content. The user
will not insert these headers themselves - detect the reply
structure and add them on output.

#### Initial output

Write model text with no `>` prefix. The question sub-heading
itself is not duplicated in the body.

```org
* questions for user
** TODO What version of FreeBSD are you targeting?
The research covers several FreeBSD-specific areas. Knowing
your version would help narrow the findings.
```

#### How the user replies

The user places a CR block after the content they want to
reply to:

```org
#+BEGIN_CR
their reply here
#+END_CR
```

The user never types `>` directly - all `>` indentation and
`%` headers are written by the model.

#### Detection

A CR block under a question sub-heading signals a user reply.
In the threaded history (content with `>` prefixes), parity
is always model-output convention: even depths (0, 2, 4...) =
model, odd depths (1, 3, 5...) = user.

Depth counts only `>` characters, not `%`. Lines containing
`model wrote:` or `user wrote:` with `%` prefixes are
attribution headers (metadata, not content).

#### Transformation

On re-run, when a CR block is found under a question:

1. Extract the CR block content (the user's reply)
2. Remove the CR block from the document
3. Increase all `>` depths on content lines by 2
4. Rewrite each `%` header line: set the `%` count to match
   the `>` depth of the content block it precedes
5. Add `% user wrote:` header above the user's reply and
   insert it at depth 1
6. Add `%% model wrote:` header above the model's previous
   reply (now at depth 2 after step 3)
7. Write new model follow-up at depth 0

#### Example progression

First run output:

```org
* questions for user
** TODO What version of FreeBSD are you targeting?
The research covers several FreeBSD-specific areas. Knowing
your version would help narrow the findings.
```

User replies with CR block:

```org
** TODO What version of FreeBSD are you targeting?
The research covers several FreeBSD-specific areas. Knowing
your version would help narrow the findings.
#+BEGIN_CR
14.2-RELEASE, but planning to upgrade soon.
#+END_CR
```

Second run output:

```org
** TODO What version of FreeBSD are you targeting?
%% model wrote:
>> The research covers several FreeBSD-specific areas. Knowing
>> your version would help narrow the findings.
% user wrote:
> 14.2-RELEASE, but planning to upgrade soon.
Would you like the research to cover both 14.2 and 15.0, or
focus on one?
```

User replies again with CR block:

```org
** TODO What version of FreeBSD are you targeting?
%% model wrote:
>> The research covers several FreeBSD-specific areas. Knowing
>> your version would help narrow the findings.
% user wrote:
> 14.2-RELEASE, but planning to upgrade soon.
Would you like the research to cover both 14.2 and 15.0, or
focus on one?
#+BEGIN_CR
Cover both, note any differences.
#+END_CR
```

Third run output:

```org
** TODO What version of FreeBSD are you targeting?
%%%% model wrote:
>>>> The research covers several FreeBSD-specific areas. Knowing
>>>> your version would help narrow the findings.
%%% user wrote:
>>> 14.2-RELEASE, but planning to upgrade soon.
%% model wrote:
>> Would you like the research to cover both 14.2 and 15.0, or
>> focus on one?
% user wrote:
> Cover both, note any differences.
Got it. Research will cover both 14.2 and 15.0, noting any
differences between versions.
```

When the user marks the question DONE, remove it entirely and
incorporate the full thread into the research.

#### Verification

Each example satisfies these invariants:

1. The most recent text is always at depth 0
2. Even depths (0, 2, 4...) = model, odd depths (1, 3, 5...) = user
3. User replies appear only in CR blocks (no depth shifting)
4. `model wrote:` headers use `%` at even depths >= 2
5. `user wrote:` headers use `%` at odd depths >= 1
6. No two adjacent content blocks share the same depth

Trace of second run transformation:
- Input: model text at depth 0, no headers
- CR block extracted: user's reply
- Step 3 (+2): depth 0 -> 2
- Step 4: no existing `%` headers
- Steps 5-6: add `%% model wrote:` (depth 2),
  `% user wrote:` (depth 1)
- Step 7: new model at depth 0
- Output depths: 2(model), 1(user), 0(model)
- Even=model ✓  Odd=user ✓

Trace of third run transformation:
- Input content depths: 2, 1, 0 (plus `%%` and `%` headers)
- CR block extracted: user's reply
- Step 3 (+2): 4, 3, 2
- Step 4: `%% model wrote:` -> `%%%% model wrote:` (depth 4),
  `% user wrote:` -> `%%% user wrote:` (depth 3)
- Steps 5-6: add `%% model wrote:` (depth 2),
  `% user wrote:` (depth 1)
- Step 7: new model at depth 0
- Output depths: 4(model), 3(user), 2(model), 1(user), 0(model)
- Even=model ✓  Odd=user ✓

### Research heading

```org
* research
```

Research findings go under this heading. Structure the content
with org sub-headings, lists, or prose as appropriate.

This heading always comes **after** the questions heading (if
present).

## Inline replies (CR blocks)

The user may reply inline to sections of the research output
using CR blocks. A CR block is placed after the content the
user wants to comment on:

```org
** Some finding
The recommended approach is X because of Y. There is also
approach W which has different tradeoffs.
#+BEGIN_CR
I tried X and it failed due to Z. Tell me more about W.
#+END_CR
```

CR blocks are valid only inside skill-managed sections (the
`* research` heading and `* questions for user` sub-headings).

On re-run, the skill reads each CR block as feedback on the
preceding content, incorporates it into the research, and
removes the block. CR blocks are not patch instructions - they
are new information to integrate into the document. The
research section is rewritten from scratch.

### Output rule

**Never start a line with `>`** in the research output. The `>`
prefix is reserved for threading history in question
sub-headings.

## Findings

Findings should be clear and concise, organized for the topic at
hand. Structure however best fits (prose, sections, bullet points,
comparison tables, etc.).

Cite sources when possible. Distinguish between what documentation
says and what community experience suggests.

## Re-run behavior

Each run produces a fresh response that:

- Incorporates any changes the user made to their content (before
  the skill headings)
- Incorporates any answers the user wrote to previous questions
- Incorporates any CR blocks the user added to research
  sections
- Reflects the latest research (not cached from prior runs)
- Removes questions that have been answered
- May restructure entirely if the user's content has evolved
- Rewrites the `--- model ---` block in the commit message

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
