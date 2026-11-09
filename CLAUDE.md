# lab

## System

FreeBSD host. Use BSD variants of tools - do not assume GNU flags.
When unsure, check `man <tool>`.

## Version Control

Working tree may be managed by jj (jujutsu) or git. Check before
working.

### Commit messages

The commit-message skill defines the house style for commit
messages. Follow it whenever you write a commit message, and whenever
you change a commit's diff or message: commit, describe, squash,
split, absorb, diffedit, resolve, or editing files in a described
change. A message must describe its diff as it stands now, all of it
and nothing else. No Co-Authored-By trailers.

## Writing style

- Do not use double spaces anywhere (content or commit messages)
- Prefer complete sentences over fragments using semicolons and dashes

## Dependencies

- Do not install dependencies.
- If you get blocked on a missing dependency, report to user the
  dependencies that need to be installed.
