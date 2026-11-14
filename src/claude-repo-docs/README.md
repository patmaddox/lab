# claude-repo-docs

`repo-docs` is a Claude Code skill for documenting code repositories.
With it installed, ask Claude to document some code, write or revise
its comments, write a README, or revise existing docs and fill their
gaps, and it follows the skill.

The skill is not specific to any repo. It learns each repo's
conventions from its `CLAUDE.md`, `AGENTS.md`, and existing docs, and
from an optional `.claude/docs.md` that overrides them.
## How it works

The skill tells Claude to read the repo's conventions and the code
before writing, and never to state a command, path, or option that
the repo does not contain. It covers three jobs: comments, new docs,
and revising docs to fill gaps. Comments explain why, and docstrings
document interfaces at their declaration.

External docs follow Diátaxis per section, not per page. Each section
serves one need, as a tutorial, how-to, reference, or explanation,
and a page may mix sections of different kinds. The skill fixes blur,
where off-mode content interrupts a section, rather than splitting
pages into four.

After a substantial change, a subagent with fresh context reviews the
docs against the code. Claude edits files in place for you to review
as a diff, and reports what it changed, what it guessed, and what it
could not find.

## Layout

- `skill/SKILL.md` is the skill, which Claude reads when a request
  matches its description.
- `skill/references/` holds the detail it loads as needed: Diátaxis
  per section, comments, gap finding, a README outline, the
  reviewer's brief, and the `.claude/docs.md` format.

To use the skill in a repo, copy `skill/` to its
`.claude/skills/repo-docs`.
