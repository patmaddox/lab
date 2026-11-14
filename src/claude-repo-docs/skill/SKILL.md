---
name: repo-docs
description: >
  Write, revise, and fill gaps in a code repository's documentation:
  comments and docstrings in source files, and the docs beside the
  code, such as READMEs, docs/ trees, guides, and man pages. Use when
  asked to document code, write or improve comments, write a README or
  other docs for a directory or project, or review, revise, or fill
  gaps in existing documentation in a repo. Not for Claude Docs, Word
  files, or commit messages.
argument-hint: "[paths] [what to do]"
---

# repo-docs

Document a repository the way a careful maintainer would: true to
the code, in the repo's own voice and formats, and no longer than the
reader needs. This skill covers three jobs, often mixed in one
request:

- **Comments.** Write or revise comments and docstrings in source
  files.
- **New docs.** Write external documentation that does not exist yet:
  a README, a guide, a reference page, a man page.
- **Revise and fill gaps.** Improve existing docs, correct what has
  drifted from the code, and add what readers need but cannot find.

The request names the paths, or `$ARGUMENTS` does. When it names
none, work on the current directory and say so.

## 1. Learn the repo's conventions

Before writing anything, read:

- `CLAUDE.md` and `AGENTS.md` files from the repo root down to the
  target paths. Their writing rules bind the docs too.
- `.claude/docs.md`, if it exists. It overrides anything inferred.
  `references/config.md` describes it.
- Two or three existing docs near the target, and the comments in
  the files you will touch. Match their format (Markdown, org, rst,
  mdoc, plain text), heading style, tone, and comment idiom.

Then settle these, and write down any you had to guess:

- **Where reference lives.** Man pages, generated API docs, or
  docstrings may already be the reference. Don't duplicate it in a
  README; link to it.
- **What not to restructure.** Specs, decision records, ADRs, RFCs,
  changelogs, generated files, vendored code, and agent instruction
  files are records, not living docs. Fix a broken link or a typo in
  one only if asked, and never reorganize it.
- **Who reads it.** Humans, agents, or both. Keep agent instructions
  (CLAUDE.md, AGENTS.md) separate from human docs.

## 2. Learn the code

Docs must be true to the code. Read the code you are documenting,
not just its existing docs. Collect the facts a reader needs from
their sources: entry points and public interfaces, commands in the
Makefile, Justfile, package scripts, or CI config, environment
variables, configuration keys, defaults, and error behavior.

**Never invent.** Every command, flag, path, option, default, and
URL you write must appear in the repo or in output you ran. If a
reader needs a fact you cannot find, leave it out and list it as an
open question in your report. Run a command to confirm what it does
only when that is safe and cheap.

## 3. Do the job

### Comments

Follow `references/comments.md`. In short, explain why rather than
what, and document each interface at its declaration. Delete comments
that are wrong or that restate the code.

### New docs, and revising docs

Follow `references/diataxis.md`. In short, every section serves one
reader need, and a page may hold sections of several kinds:

- **Tutorial:** a lesson in which the reader learns by doing.
- **How-to:** steps to reach a goal the reader already has.
- **Reference:** facts to look up, complete and terse.
- **Explanation:** context and the reasons things are as they are.

Classify each section, not each page. Mixing is fine when each part
is short or sits in its own headed section. Fix blur: a run of
off-mode content that interrupts what the section is for. Never
create empty sections to fill out a structure.

For a new README, start from `references/readme.md`. Keep it to the
minimum a newcomer needs, and link out for the rest.

### Gaps

Follow `references/gaps.md` to compare what the docs say against
what the code does and what readers need. Fill the gaps that matter
most. Prefer correcting and deleting stale or duplicated docs over
adding new ones, and say which you chose.

Grow a doc only as far as its readers need. If a revision would more
than double a doc's length, check each addition against the reader
it serves, and cut what only completes the picture. Say in your
report how much the doc grew and why.

## 4. Review with fresh eyes

When you have written or changed more than a few lines of prose,
start a subagent with no context from this session to review it.
Give it the brief in `references/review.md`, the paths you changed,
and nothing about your intentions. Apply what it finds that holds
up. Skip this for comment-only changes of a few lines.

## 5. Edit, then report

Edit the files in place. The user reviews the diff, so keep it
focused: change what the request covers, and leave unrelated text,
formatting, and line wrapping alone. Keep the author's voice when
revising.

Finish with a short report:

- Each file changed, with one line on what changed and why.
- Conventions you inferred that the user may want to confirm or
  record in `.claude/docs.md`.
- Open questions: facts the docs need that the repo does not state.
- Gaps you saw but left alone, if any.
