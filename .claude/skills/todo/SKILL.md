---
description: Add or update a TODO item in todo.org
user-invocable: true
allowed-tools: Read, Edit, Bash
---

# todo

Add or update a TODO entry in `$(jj root)/todo.org` from the prompt
arguments.

## Process

1. Read the current `todo.org`.
2. Check if an existing entry covers the same idea or would benefit
   from incorporating `$ARGUMENTS`. Look for thematic overlap, not
   just keyword matches.
3. If a good fit exists, update that entry — expand the body, refine
   the title, or add the new angle. Do not lose existing content.
4. If no existing entry fits, append a new `* TODO` entry:
   - First line: `* TODO <concise title>`
   - Body: 1-3 lines expanding on the idea if needed
5. Commit with `jj commit -m '[CLAUDE] todo: <concise title>'`.
   Use the title of whichever entry was added or updated.
