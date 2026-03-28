---
status: draft
---

# Add a commit prompt with commit instructions

Pull the commit behavior out of CLAUDE.md and into a dedicated
prompt in `prompts/commit.md`, similar to how `plan.md` and
`implement.md` work.

CLAUDE.md currently has commit message style rules (FreeBSD
conventions, subject line format, body wrapping) and the `jj
commit -m` instruction. A commit prompt would own the full
commit workflow - reviewing the diff, crafting the message,
and making the commit - so CLAUDE.md only needs to say "use the
commit prompt."

## Open questions

> What should the commit prompt actually do beyond writing a
> message and running `jj commit -m`? For example, should it
> review the diff for quality, split large changes, squash
> fixups into earlier commits?

> Should the commit prompt be invoked as a skill (like
> `/commit`) or just referenced by other prompts (like
> `implement.md` could call it)?

> The recently removed instructions mentioned splitting,
> squashing, reordering, and abandoning commits to keep history
> clean. Should any of that come back in the commit prompt, or
> is that out of scope?

> Should committing be standalone - starting with no context,
> reading the current diff, and producing a commit message
> purely from what it sees - or contextual, running at the end
> of another task (e.g. implement) where the context already
> knows what it changed and why? The standalone approach is
> simpler and composable, but a contextual commit might write a
> better "why" in the commit message. Which produces the better
> commit?
