# claude-repo-docs

A FreeBSD package that installs `repo-docs`, a Claude Code skill for
documenting code repositories. With it installed, ask Claude to
document some code, write or revise its comments, write a README, or
revise existing docs and fill their gaps, and it follows the skill.

The skill is not specific to any repo. It learns each repo's
conventions from its `CLAUDE.md`, `AGENTS.md`, and existing docs, and
from an optional `.claude/docs.md` that overrides them.

## Install

The package installs the skill as a managed skill, under
`/usr/local/etc/claude-code/.claude/skills/repo-docs`. Claude Code
reads managed skills only from `/etc/claude-code`, so that must link
to `/usr/local/etc/claude-code`. yolo's coding-agent jails have the
link already. On another host, make it first:

    doas ln -s ../usr/local/etc/claude-code /etc/claude-code

Then build and install the package:

    just install

## How it works

The skill tells Claude to read the repo's conventions and the code
before writing, and never to state a command, path, or option that
the repo does not contain. It covers three jobs: comments, new docs,
and revising docs to fill gaps. Comments explain why, and docstrings
document interfaces at their declaration. Docs describe the tree as
it stands, and leave the story of a change to its commit message, so
the two don't repeat each other. The skill carries a
short form of revise-prose's rule.

Docs are written for a skilled operator who is new to the project,
unless the repo names other readers. Revising a doc means editing its
existing text as well as adding to it: the skill cuts what that
reader already knows, along with filler and repetition, and tightens
what remains.

External docs follow Diátaxis per section, not per page. Each section
serves one need, as a tutorial, how-to, reference, or explanation,
and a page may mix sections of different kinds. The skill fixes blur,
where off-mode content interrupts a section, rather than splitting
pages into four.

Claude checks what it changed with the tools the FreeBSD
Documentation Project uses: mandoc -Tlint and igor for man pages,
aspell for spelling, Vale for prose, and codespell for comments. The
package depends on all of them. After a substantial change, a
subagent with fresh context also reviews the docs against the code. Claude edits files in place for you to review
as a diff, and reports what it changed, what it guessed, and what it
could not find.

## Layout

- `skill/SKILL.md` is the skill, which Claude reads when a request
  matches its description.
- `skill/references/` holds the detail it loads as needed: Diátaxis
  per section, comments, gap finding, a README outline, man pages in
  FreeBSD-style mdoc(7), the checking tools, the reviewer's brief, and
  the `.claude/docs.md` format.
- `skill/vale.ini` is the Vale config the skill uses in a repo that
  has none.
- `claude-repo-docs.pkg.do` builds the package with redo.

To try a change to the skill without a package, copy `skill/` to a
repo's `.claude/skills/repo-docs`.
