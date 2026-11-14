# Comments and docstrings

A comment earns its place by telling the reader something the code
cannot. Follow the conventions of the language and of the file. When
the two differ, follow the file.

## What to write

- **Why, not what.** Explain intent, constraints, and the reason for a
  surprising choice. "Retry once, because the first read after
  failover returns stale data" helps. "Increment i" does not.
- **Interfaces at their declaration.** Document each public function,
  type, module, command, and configuration key where it is declared,
  in the language's docstring form (godoc, rustdoc, Python docstrings,
  JSDoc, Javadoc, Doxygen). Say what it does, its inputs and outputs,
  its errors, and its side effects. These docstrings are reference,
  so keep them terse and complete.
- **A header for each file or module** whose purpose is not obvious
  from its name. Say what it is for and where to start reading.
- **Invariants and contracts.** What must hold before and after a call,
  who owns a resource, what must not happen concurrently.
- **Pointers.** Link a workaround to its bug, a magic number to its
  source, and an algorithm to its paper or spec.
- **Shell scripts** get a header saying what the script does, how to
  run it, and the variables it reads.

## What not to write

- Comments that restate the code, narrate obvious steps, or label
  sections that the code already makes clear.
- History. "Changed from X to Y" and "fixed bug" belong in commit
  messages.
- Commented-out code. Delete it.
- Notes addressed to the reviewer or the session, such as "updated
  per request."
- Claims you have not checked. A wrong comment costs more than no
  comment.

## Revising comments

- Read the code, then check every existing comment against it. Correct
  or delete the ones that are wrong, and delete the ones that add
  nothing.
- Keep TODO, FIXME, and similar markers unless the work they describe
  is done. Keep the repo's marker format.
- Don't reformat, rewrap, or restyle comments you are not otherwise
  changing.
- Change comments only. Don't change code, not even whitespace,
  unless asked. If the code looks wrong, report it.

## Comments and external docs together

A docstring and a README or reference page should not repeat each
other. Let the docstring be the reference for an interface, and let
external docs explain, guide, and link to it. If the repo generates
docs from comments, the comments are the source, so fix the comments,
not the generated docs.
