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

Only modify commits that descend from the `claude_start()` revset. Never rewrite, squash into, or otherwise alter commits outside that range.

Always reference jj change IDs (e.g. `kmnwrmrx`), not git commit hashes.

Always use `--git` with `jj diff` and `jj show` for line-separated diffs. The default format combines changes on single lines which is harder to read.

Before committing, review the diff and recent history. "Commit" means do whatever is needed: split, squash, reorder, or abandon commits to keep history clean. Use `jj squash --into` to fold later fixes into earlier commits when appropriate. Abandon commits that are made obsolete by later work. Do not create commits that only change task state — include the state change in the commit that does the actual work.

Commit message style follows FreeBSD conventions:
- Subject line: ~50 chars, imperative mood, prefixed with `[CLAUDE] <area>: ` where `<area>` matches the relevant subdirectory (e.g. `[CLAUDE] emacs: Add org-capture template`). If the change spans multiple areas or is repo-wide, omit the area (e.g. `[CLAUDE] Promote version control rules`)
- Bracketed prefixes like [CLAUDE] or [WIP] are excluded from the ~50 char count (they are temporary and will be removed)
- Wrap body at 72 characters
- Explain why, not what — the diff shows what changed
- Reference: https://docs.freebsd.org/en/articles/committers-guide/#commit-log-message

## Vendored Code

If vendoring third-party code, see `dotfiles/emacs/CLAUDE.md` for the established pattern. If the pattern gets reused elsewhere, promote it here.
