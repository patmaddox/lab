# .claude/docs.md

A repo may keep a `.claude/docs.md` to state its documentation
conventions. It is optional. When it exists, it overrides what the
skill would otherwise infer. When the skill has to guess a convention,
it says so in its report, so the user can record the answer here.

It is plain Markdown. Use only the sections that apply:

```markdown
# Documentation conventions

## Formats
Docs are org-mode, except READMEs for GitHub-facing projects, which
are Markdown. CLI tools have mdoc man pages.

## Reference
The man page is the reference for each command. READMEs link to it
and don't repeat options.

## Leave alone
- spec.org, lore.org, decisions.org: the author's records.
- plans/: proposals with their own format.
- vendor/, third_party/: upstream code.

## Style
Complete sentences. No double spaces. Second person in how-tos.

## Readers
Contributors on FreeBSD who know make and jails.
```

Without a Readers section, the skill writes for a skilled operator new
to the project.

Keep it short. Anything here applies to every doc the skill touches
in the repo. Don't repeat rules that CLAUDE.md already states.
