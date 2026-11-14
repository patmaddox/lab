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
- **Revise and fill gaps.** Trim and tighten existing docs, correct
  what has drifted from the code, and add what readers need but cannot
  find.

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
  (CLAUDE.md, AGENTS.md) separate from human docs. Unless the repo
  says otherwise, write for a skilled operator: fluent in the
  platform, the shell, and the tools the repo uses, and new only to
  this project. Give them facts and commands. Don't explain standard
  tools, define common terms, or spell out steps they already know.

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

Write every sentence, in docs and comments, by `references/style.md`:
one name per thing, actors as subjects and actions as verbs, old
information before new, and no fact lost in tightening.

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
minimum a skilled operator new to the project needs, and link out for
the rest.

### Trim and tighten

Treat existing text as a draft, not a given. When revising a doc,
edit what is there, not only what you add. Every sentence must earn
its place with a skilled operator. Cut or shorten:

- Explanations of standard tools, commands, and concepts.
- Sentences that restate the heading, the sentence before, or another
  section.
- Signposting and throat-clearing: "This section describes", "Note
  that", "It is important to".
- Filler and hedges: "simply", "just", "basically", "in order to",
  "please", "you may want to".
- Prose that a command, list, or table says better.
- Caveats for cases the reader will not hit.

Tighten what remains by `references/style.md`, with the fewest words
that keep the meaning. Keep every fact, every warning about
destructive or surprising behavior, and the author's terms.
Expect a revision to leave a doc shorter, unless it fills a real gap.

### Docs describe the tree, not the change

Docs and comments say how things are, for a reader of the tree long
after this change. Don't narrate change in them: "now supports",
"was changed to", "no longer", "new in this version". That belongs
in the commit message, which describes the status quo before the
change and its problem. A change users must act on may also go in
upgrade notes or a HISTORY section, where the repo keeps them.

The docs, comments, and message must not repeat each other beyond a
clause or a pointer, and no one of them ranks above the others. Put
a design decision's reasons where the reader who would question it
looks: in the docs or a comment if a user or maintainer would
question it while reading the tree, even if the reasons also
motivate the commit, and in the message if only someone reviewing
or tracing the change would ask. Weigh a comment against the docs
by scope: one piece of code, or the whole. If the revise-prose skill
is available, it decides where each idea goes, and the prose-editor
agent reconciles a series of commits by it.

### Man pages

To write or revise a Unix manual page, follow `references/man-pages.md`.
It uses mdoc(7) in FreeBSD style. A man page is the reference for a
command, so the README and other docs link to it rather than repeat
its options. Offer to write one when a command-line tool has none
and the repo's other tools have them.

### Gaps

Follow `references/gaps.md` to compare what the docs say against
what the code does and what readers need. Fill the gaps that matter
most. Prefer correcting and deleting stale or duplicated docs over
adding new ones, and say which you chose.

Grow a doc only as far as its readers need. If a revision would more
than double a doc's length, check each addition against the reader
it serves, and cut what only completes the picture.

## 4. Check with tools

Run the checks in `references/checks.md` on the files you changed:
mandoc and igor for man pages, and Vale, codespell, and aspell for
prose and comments. Fix what is real, and judge the rest.

## 5. Review with fresh eyes

When you have written or changed more than a few lines of prose,
start a subagent with no context from this session to review it.
Give it the brief in `references/review.md`, the paths you changed,
and nothing about your intentions. Apply what it finds that holds
up. Skip this for comment-only changes of a few lines.

## 6. Edit, then report

Edit the files in place. The user reviews the diff, so keep it
focused on what the request covers. A request to revise a doc covers
all of its text, so trim and tighten throughout. A request about one
section covers that section. Leave other text alone, and don't rewrap
lines you did not otherwise change. Keep the author's voice while
tightening it.

Finish with a short report:

- Each file changed, with one line on what changed and why, and how
  much it grew or shrank.
- Conventions you inferred that the user may want to confirm or
  record in `.claude/docs.md`.
- Open questions: facts the docs need that the repo does not state.
- Gaps you saw but left alone, if any.
