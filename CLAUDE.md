# lab.jj

## System

This runs on FreeBSD. Use FreeBSD (BSD) variants of tools — `make`, `grep`, `sed`, `awk`, etc. Do not assume GNU flags or behavior. When unsure how to use a tool, read its man page with `man <tool>`.

## Writing style

Use single ASCII hyphens (-) for dashes, not double hyphens (--) or em dashes.

## Directory READMEs

When working in any directory, check for a README file (README,
README.md, README.txt, README.org, etc.) and read it before
proceeding. READMEs contain context about the directory's purpose,
conventions, and how to work with its contents.

## Repo Structure

.org files are emacs org-mode files

- `dotfiles/emacs/` — Emacs configuration (has its own CLAUDE.md)
- `notebook/fieldstones.org` notes reminiscent of Gerald Weinberg fieldstone method
- `notebook/tasks.org` task list

## Version Control

This repo uses jj (Jujutsu) for version control.

Use `jj commit -m` to commit after successful work. Do not commit after errors.

Never run `just promote` or `promote.sh` — promotion is done manually.

### Concurrency lock

Multiple Claude sessions share the same working copy. Hold the
repo lock while running jj operations. Do not hold it across
turns — scripted sessions need to run between interactive turns.

Wrap all jj commands for a turn in a single `lockf` invocation:
```sh
lockf -k "$(jj root)/.jj/claude.lock" sh -c '
  jj squash --into foo
  jj log -r ..@ --no-graph -n 5
'
```

The `-k` flag keeps the lock file between uses, which guarantees
ordering and reduces CPU churn from concurrent create/delete cycles.
`lockf` blocks if another session holds the lock and releases
automatically when the `sh -c` exits — no background processes,
no PID files, no cleanup needed.

Scripted sessions use `libexec/just/claude-run.sh` which handles
locking automatically.

### Working with commits

Only modify `mutable()` commits. Never modify immutable commits.

Always use `--git` with `jj diff` and `jj show` for line-separated diffs. The default format combines changes on single lines which is harder to read.

Commit message style follows FreeBSD conventions:
- Subject line: ~50 chars, imperative mood, prefixed with `[CLAUDE] <area>: ` where `<area>` matches the relevant subdirectory (e.g. `[CLAUDE] emacs: Add org-capture template`). Use `claude:` for changes to CLAUDE.md, `.claude/` skills, and Claude infrastructure (e.g. `[CLAUDE] claude: Add stay-at-tip rule`). If the change spans multiple areas or is repo-wide, omit the area (e.g. `[CLAUDE] Promote version control rules`)
- Bracketed prefixes like [CLAUDE] or [WIP] are excluded from the ~50 char count (they are temporary and will be removed)
- Wrap body at 72 characters
- Explain why, not what — the diff shows what changed
- Do not add Co-Authored-By trailers
- Reference: https://docs.freebsd.org/en/articles/committers-guide/#commit-log-message

## Prior thinking

When discussing a topic — especially planning, design, or ideas —
check these locations for existing context before starting fresh:
- `fieldstones.org` — ideas, design rationale, connections, analogies
- `todo.org` — actionable items and writing topics
- `notes/` — longer-form notes (if present)

The user has often already captured partial thoughts. Build on what
exists rather than starting from scratch.

## Fieldstones

`fieldstones.org` is a living document of ideas and thinking that
develops during conversations. Proactively update it when you notice:
- Design rationale or "why" behind decisions
- Analogies and connections between concepts
- Principles or patterns that emerge from the work
- Ideas worth remembering that aren't actionable TODOs

Include updates in the commit for the turn where the thinking
happened — do not create separate fieldstone-only commits. Use org
headings (`* Title`) to organize by theme. Merge into existing
entries when the idea extends prior thinking.

`fieldstones.org` and `todo.org` are collaborative documents — the
user edits them directly in emacs. **Always re-read the file
immediately before modifying it.** Never rely on a previously read
version. Never use the Write tool to overwrite the entire file —
use Edit to make targeted changes. When squashing commits that
touch these files, verify the current file content first to avoid
discarding the user's edits.
## Vendored Code

If vendoring third-party code, see `dotfiles/emacs/CLAUDE.md` for the established pattern. If the pattern gets reused elsewhere, promote it here.
