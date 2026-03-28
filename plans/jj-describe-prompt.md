---
status: draft
---

# Add a jj-describe prompt for writing commit messages

A prompt (or skill) that takes a change ID, examines the diff,
and writes a commit message via `jj describe`. Useful for changes
that were committed without a description, or that need a better
one.

## Open questions

> How does this relate to the commit prompt in
> `plans/commit-prompt.md`? Is this a subset of that work, or a
> separate tool? `jj commit` creates a new change on top, while
> `jj describe` only updates the description - they serve
> different moments in the workflow.

> Should this be a skill (e.g. `/describe m`) so the user can
> invoke it directly, or a prompt that other workflows call?

## Motivation

The natural way to ask for this is "look at change `m` and
describe it" but it's easy to miscommunicate the change ID vs
jj flags. A dedicated prompt makes the workflow unambiguous:
give it a change, get a description.

> How does this relate to the commit prompt in
> `plans/commit-prompt.md`? Is this a subset of that work, or a
> separate tool? `jj commit` creates a new change on top, while
> `jj describe` only updates the description - they serve
> different moments in the workflow.

> Should this be a skill (e.g. `/describe m`) so the user can
> invoke it directly, or a prompt that other workflows call?
