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
