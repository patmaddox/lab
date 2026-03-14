# lab.jj

## System

This runs on FreeBSD. Use FreeBSD (BSD) variants of tools — `make`, `grep`, `sed`, `awk`, etc. Do not assume GNU flags or behavior. When unsure how to use a tool, read its man page with `man <tool>`.

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

Multiple Claude sessions share the same working copy. Acquire the
repo lock before jj operations within a turn, and release it when
the turn's jj work is done. Do not hold the lock across turns —
scripted sessions need to run between interactive turns.

```sh
# Acquire (before jj work in a turn):
lock="$(jj root)/.jj/claude.lock"
nohup lockf -k "$lock" sleep 86400 >/dev/null 2>&1 &
echo $! > "$(jj root)/.jj/claude.lock.pid"

# Release (after jj work in the same turn):
kill $(cat "$(jj root)/.jj/claude.lock.pid") 2>/dev/null
rm -f "$(jj root)/.jj/claude.lock.pid"
```

The `-k` flag keeps the lock file between uses, which guarantees
ordering and reduces CPU churn from concurrent create/delete cycles.
The `sleep 86400` is just a long-lived process to hold the fd open;
it gets killed explicitly on release, so the value doesn't matter.

If the lock is already held, `lockf` will block until it is released.
Scripted sessions use `libexec/just/claude-run.sh` which handles
locking automatically.

### Working copy protocol

Always begin and end a session on an empty commit that is the youngest
descendant of `wip::`. Before doing work, verify this:
```sh
jj log -r 'latest(wip::)' --no-graph
```
If the tip has changes, run `jj new` to create an empty commit on top.
When finished, if `@` has uncommitted changes, run `jj new` to leave
a clean empty commit at the tip.

Only modify commits that have `[CLAUDE]` in the description with no other tags (no `[REVIEW]`, `[FEEDBACK]`, etc.), or commits with no description (WIP work). Never modify commits outside this set. Exception: when running `/pm-feedback`, you may modify any commit with `[CLAUDE]` in the description regardless of other tags.

Always reference jj change IDs (e.g. `kmnwrmrx`), not git commit hashes.

Always use `--git` with `jj diff` and `jj show` for line-separated diffs. The default format combines changes on single lines which is harder to read.

Before committing, review the diff and recent history. "Commit" means do whatever is needed: split, squash, reorder, or abandon commits to keep history clean. Use `jj squash --into` to fold later fixes into earlier commits when appropriate. When squashing into a commit, review the commit message to ensure it still accurately describes the commit's content. Abandon commits that are made obsolete by later work. Do not create commits that only change task state — include the state change in the commit that does the actual work.

Commit message style follows FreeBSD conventions:
- Subject line: ~50 chars, imperative mood, prefixed with `[CLAUDE] <area>: ` where `<area>` matches the relevant subdirectory (e.g. `[CLAUDE] emacs: Add org-capture template`). If the change spans multiple areas or is repo-wide, omit the area (e.g. `[CLAUDE] Promote version control rules`)
- Bracketed prefixes like [CLAUDE] or [WIP] are excluded from the ~50 char count (they are temporary and will be removed)
- Wrap body at 72 characters
- Explain why, not what — the diff shows what changed
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

## Vendored Code

If vendoring third-party code, see `dotfiles/emacs/CLAUDE.md` for the established pattern. If the pattern gets reused elsewhere, promote it here.
