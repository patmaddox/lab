---
description: >
  Research a topic based on the user's org-mode document. Reads the
  document, researches thoroughly, and writes findings below the
  user's content.
  TRIGGER when the user says /research or asks to research a document.
user-invocable: true
argument-hint: "<file> or jj:<revset>"
allowed-tools: Read, Edit, Write, Bash, Grep, Glob, WebFetch, WebSearch, Agent
---

# research

Research the topic described in a user's org-mode document and write
findings back into the same file.

## Input

`$ARGUMENTS` is either a path to an .org file, or a jj revset
prefixed with `jj:`.

### File mode

When `$ARGUMENTS` is a path to an .org file, read it first and
proceed to researching.

### jj mode

When `$ARGUMENTS` starts with `jj:`, the text after the prefix is
a jj revset (e.g. `jj:@` or `jj:abc123`).

1. Read the commit message from the revset:
   ```
   jj log -r <revset> --no-graph -T 'description'
   ```
2. The commit message is the user's research prompt.
3. Create a new .org file at `doc/llm-research/<slug>.org` where
   `<slug>` is derived from the commit message subject line
   (lowercase, spaces to hyphens, stripped of the `<area>: ` prefix
   and any non-alphanumeric characters besides hyphens).
4. Write the commit message body (everything after the subject
   line) as the user's content in the new file.
5. Proceed with research as normal, writing findings into the new
   file.

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

The user quotes the entire previous output by prefixing every
line with `>` (including `%` header lines), then writes their
reply at depth 0.

#### Detection

In any state of the document, the most recent text has no `>`
prefix. The parity of who is at which depth alternates between
input and output:

- **In model output**: even depths (0, 2, 4...) = model,
  odd depths (1, 3, 5...) = user
- **In user input**: even depths (0, 2, 4...) = user,
  odd depths (1, 3, 5...) = model

Depth counts only `>` characters, not `%`. Lines containing
`model wrote:` or `user wrote:` with `%` prefixes are
attribution headers (metadata, not content).

#### Transformation

On re-run, the user has already shifted all previous content
by +1 via blanket quoting. The skill increases by 1 more:

1. Increase all `>` depths on content lines by 1
2. Rewrite each `%` header line: set the `%` count to match
   the `>` depth of the content block it precedes (drop any
   `>` the user added)
3. Add a `% user wrote:` header above the user's reply
   (now at depth 1 after step 1)
4. Add a `%% model wrote:` header above the model's
   previous reply (now at depth 2 after step 1)
5. Write new model follow-up at depth 0

#### Example progression

First run output:

```org
* questions for user
** TODO What version of FreeBSD are you targeting?
The research covers several FreeBSD-specific areas. Knowing
your version would help narrow the findings.
```

User replies (blanket `>` on all lines, reply at depth 0):

```org
** TODO What version of FreeBSD are you targeting?
> The research covers several FreeBSD-specific areas. Knowing
> your version would help narrow the findings.
14.2-RELEASE, but planning to upgrade soon.
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

User replies again (blanket `>` on all lines):

```org
** TODO What version of FreeBSD are you targeting?
> %% model wrote:
> >> The research covers several FreeBSD-specific areas. Knowing
> >> your version would help narrow the findings.
> % user wrote:
> > 14.2-RELEASE, but planning to upgrade soon.
> Would you like the research to cover both 14.2 and 15.0, or
> focus on one?
Cover both, note any differences.
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
2. In model output: even depths = model, odd depths = user
3. In user input: even depths = user, odd depths = model
4. `model wrote:` headers use `%` at even depths >= 2
5. `user wrote:` headers use `%` at odd depths >= 1
6. No two adjacent content blocks share the same depth

Trace of second run transformation:
- Input content depths: 1 (model), 0 (user)
- Step 1 (+1): 2, 1
- Step 2: no existing `%` headers
- Steps 3-4: add `%% model wrote:` (depth 2),
  `% user wrote:` (depth 1)
- Step 5: new model at depth 0
- Output depths: 2(model), 1(user), 0(model)
- Even=model ✓  Odd=user ✓

Trace of third run transformation:
- Input content depths: 3, 2, 1, 0
- Step 1 (+1): 4, 3, 2, 1
- Step 2: `> %% model wrote:` -> `%%%% model wrote:` (depth 4),
  `> % user wrote:` -> `%%% user wrote:` (depth 3)
- Steps 3-4: add `%% model wrote:` (depth 2),
  `% user wrote:` (depth 1)
- Step 5: new model at depth 0
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

## Inline replies

The user may reply inline to sections of the research output
using mailing-list-style quoting. Lines prefixed with `>` are
the skill's previous output quoted back; lines without `>` are
the user's commentary.

Example:

```org
** Some finding
> The recommended approach is X because of Y.
Actually I tried X and it failed due to Z.

> There is also approach W.
This looks promising, tell me more about W.

> Some other detail.
```

When a section contains `>` quoted lines:

- Quoted lines (`>`) are the skill's previous text
- Unquoted lines are the user's feedback
- Sections with no `>` lines at all have no user feedback

Inline replies are feedback, not patch instructions. Treat them
the same as any other user input - read them, understand the
user's perspective, and then write the best complete research
response from scratch. The quoted exchange is removed when the
research heading is rewritten.

### Output rule

**Never start a line with `>`** in the research output. The `>`
prefix is reserved for the user's quoting mechanism. Starting a
line with `>` would be misinterpreted as quoted text on the next
iteration.

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
- Incorporates any inline replies the user added to research
  sections
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
