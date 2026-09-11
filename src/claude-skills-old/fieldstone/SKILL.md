---
description: Collect a fieldstone into fieldstones.org
user-invocable: true
allowed-tools: Read, Edit, Bash
---

# fs

Collect a fieldstone into `$(jj root)/fieldstones.org`.

## Process

1. Read the current `fieldstones.org`.
2. Check if an existing entry covers the same theme or would benefit
   from incorporating `$ARGUMENTS`. Look for thematic overlap, not
   just keyword matches.
3. If a good fit exists, update that entry — expand the body, add
   the new angle, refine the thinking. Do not lose existing content.
4. If no existing entry fits, append a new entry:
   - Heading: `* <concise theme>`
   - Body: capture the idea in 2-5 lines
5. Commit with `jj commit -m '[CLAUDE] fieldstone: <concise theme>'`.
   Use the heading of whichever entry was added or updated.
