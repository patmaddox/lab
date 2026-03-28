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

Stay at the tip of `wip::` — do not `jj edit` or `jj new` to jump
to other commits. Instead, use `jj squash --into` to modify earlier
commits from the tip, and `jj file show`/`jj file list` to read
files at other revisions. This avoids disrupting the working copy.

Always use `--git` with `jj diff` and `jj show` for line-separated diffs. The default format combines changes on single lines which is harder to read.

Before committing, review the diff and recent history. "Commit" means do whatever is needed: split, squash, reorder, or abandon commits to keep history clean. Use `jj squash --into` to fold later fixes into earlier commits when appropriate. When squashing into a commit, review the commit message to ensure it still accurately describes the commit's content. Abandon commits that are made obsolete by later work. Do not create commits that only change task state — include the state change in the commit that does the actual work.

Commit message style follows FreeBSD conventions:
- Subject line: ~50 chars, imperative mood, prefixed with `[CLAUDE] <area>: ` where `<area>` matches the relevant subdirectory (e.g. `[CLAUDE] emacs: Add org-capture template`). Use `claude:` for changes to CLAUDE.md, `.claude/` skills, and Claude infrastructure (e.g. `[CLAUDE] claude: Add stay-at-tip rule`). If the change spans multiple areas or is repo-wide, omit the area (e.g. `[CLAUDE] Promote version control rules`)
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

`fieldstones.org` and `todo.org` are collaborative documents — the
user edits them directly in emacs. **Always re-read the file
immediately before modifying it.** Never rely on a previously read
version. Never use the Write tool to overwrite the entire file —
use Edit to make targeted changes. When squashing commits that
touch these files, verify the current file content first to avoid
discarding the user's edits.

## Plans

Plans are LLM-executable specs for chunks of work. They live in
`plans/` at the repo root (for repo-wide work) or in a project's
own `plans/` directory (e.g. `oss/freebsd-src/plans/`).

### Format

Each plan is a separate markdown file with YAML frontmatter:

```markdown
---
status: draft | ready | active | done | abandoned | rejected
depends: [other-plan-name]
priority: low | medium | high  (optional)
---

# Short descriptive title

Content varies by maturity — a stub may be just a sentence,
a ready-to-execute plan has Goal, Context, Tasks, Done-when.
```

### Lifecycle

Plans are a corpus at varying levels of detail, not an ordered
backlog. A plan starts as a stub and gets fleshed out when ready
to work on. Status tracks the lifecycle:

- **draft**: idea captured, not yet detailed enough to execute
- **ready**: plan is clear and ready to be picked up
- **active**: currently being worked on
- **done/abandoned/rejected**: move to `plans/archive/` and add
  a Postmortem section

Active plans (draft, ready, active) stay in `plans/`.
Completed plans move to `plans/archive/`.

### Executing a plan

When asked to execute a plan, read it and implement the tasks.
When the plan is complete, update its status to `done` and add
a Postmortem section:

```markdown
## Postmortem
### Claude
What worked, what was unclear, what needed adjustment.
### Pat
(filled in by Pat after reviewing the work)
```

### Checking dependencies

Before starting a plan with `depends`, verify the dependencies
are satisfied (status is `done`). If not, flag this.

### INDEX.md

Run `make` in the plans/ directory to regenerate `INDEX.md` from
frontmatter. INDEX.md is generated — do not edit it by hand.

### Relationship to other docs

- **README.md / DESIGN.md**: durable, human-readable docs about
  architecture and design. Plans reference these for context.
  Plans produce updates to these docs as part of their work.
- **fieldstones.org**: design rationale and thinking. Plans may
  generate new fieldstones during execution.
- **CLAUDE.md**: directives for LLM behavior. Plans may produce
  updates to CLAUDE.md when new conventions are established.

## Vendored Code

If vendoring third-party code, see `dotfiles/emacs/CLAUDE.md` for the established pattern. If the pattern gets reused elsewhere, promote it here.
