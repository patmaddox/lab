# lab.jj

## System

FreeBSD host. Use BSD variants of tools - do not assume GNU flags.
When unsure, check `man <tool>`.

## Version Control

This repo uses jj (Jujutsu), not git.

Use `jj commit -m` to commit after successful work. Do not commit
after errors. Never run `just promote` or `promote.sh`.

Only modify `mutable()` commits. Always use `--git` with `jj diff`
and `jj show`.

### Concurrency lock

Multiple Claude sessions share the same working copy. Wrap all jj
commands for a turn in a single lockf invocation:

    lockf -k "$(jj root)/.jj/claude.lock" sh -c '
      jj squash --into foo
      jj log -r ..@ --no-graph -n 5
    '

Scripted sessions use `libexec/just/claude-run.sh` which handles
locking automatically.

### Commit messages

FreeBSD style. Subject ~50 chars, imperative mood, prefixed with
`<area>: ` where area matches the subdirectory. Body wrapped at
72 chars - explain why, not what. No Co-Authored-By trailers.

Good body: "Cloning prints a detached HEAD advisory and progress
           info that clutter handler output, making errors harder
           to spot."
Bad body:  "Set advice.detachedHead=false on the clone command and
           pass -q to suppress all clone noise."

The diff already shows what changed. The body should say why it
matters.

## Mail

The lab-devel mailing list is the primary channel for work. It is a
maildir committed to jj on the `mail` bookmark and read with notmuch;
"mail", "email", "your mail", "the inbox", "the list", and "check
your mail" all mean this list. They never mean Gmail or any Google or
other external mail service - do not reach for those tools here.

Two remotes, two directions. You **pull from `upstream`** (canonical
`trunk` and `mail`; read-only to you) and **push to `inbox`** (your
outbox). `inbox` is yours to push freely - the maintainer only reads
from it and merges what they accept - so publishing your `claude/*`
bookmarks there is expected and never needs approval:

    lockf -k "$(jj root)/.jj/claude.lock" \
        jj git push --remote inbox --bookmark claude/mail

To act on the list, use the `check-mail` skill (`claude-mail-run` is
the headless equivalent). One pass takes the single most important
open thread - a message addressed to you with no reply yet - does the
work, submits the result onto `claude/mail`, pushes to `inbox`, and
starts fresh. Loop it to drain the queue, or keep going within one
session when context should carry across threads. doc/mail-workflow.md
has the full picture.

## Own the loop

Never take control signals from a coding agent's output. A tool that
reads its own control tokens back from that output will misfire,
because model output is not deterministic. This is what broke sclr. It
read the string sclr:done from stdout, and while working on its own
prompts the model repeated that string, so sclr stopped early.

What we want is a loop whose control never depends on what the model
happened to print. The result of a turn should be visible from outside
the model, in a place the model can only change by taking a real
action.

So pipe agent output to /dev/null, and key control on side effects you
can check. Look for a signal file, a commit, a moved bookmark, a
delivered message. Check for the positive fact, e.g. "report.org
exists" or "the commit landed", not a parsed string. The channels you
can trust are the ones the model does not author, i.e. the exit code,
the filesystem, and the VCS state. If a turn must hand back data, have
the model write it to a named file with a known shape, then validate
that file.
