+++
template = "index.html"
aliases = [
  "doc/trunk/www/"
]
+++

# Home

<center>
<form action='$ROOT/docsrch' method='GET'>
<input type="text" name="s" size="40" autofocus>
<input type="submit" value="Search">
</form>
</center>

This is my [monorepo](@/_old/why-monorepo.md).

## Writing

- [First steps in programming FreeBSD: Reading process information](@/_old/programming-freebsd-reading-process-information.md)
- [sh: Relative shell script includes with realpath on FreeBSD](@/_old/sh-relative-shell-script-includes-with-realpath-on-freebsd.md)
- [Lenovo T14 Gen 2 AMD - a fine laptop for FreeBSD (with a wifi caveat)](@/_old/lenovo-t14-gen2-amd-a-fine-laptop-for-freebsd.md)

## Primary Purpose

Iterate my way to a personal computing setup that I love, and that grows with my needs and wants.

## What I'm up to

- [open source contributions](@/_old/open-source-contributions.md) - contributions to upstream projects

Here are the specific branches or directories that are primarily of interest to me at the moment:

## Other considerations

Working with this repo feels a bit like [Jerry Weinberg's Fieldstone Method](https://geraldmweinberg.com/Site/On_Writing.html), applied to code.
I start things in `experiments/`, and grow them as I see fit.
When I've built up something solid, I can incocorporate it into my over all system.

This repo is my home dir on a FreeBSD system.
I had considered trying to make it portable with MacOS.
I ended up getting a FreeBSD laptop instead, and I'm happier for it.

## Links

- [What I like about Fossil](@/_old/what-i-like-about-fossil.md)
- [Why a monorepo?](@/_old/why-monorepo.md)

## Subprojects

### ports

- [ ] use an overlay dir instead of git worktrees
  - I had stopped using it because of some problem with poudriere.
    I forget what it was.
    Git worktrees are kind of a pain to maintain though.
    I can either go back to poudriere overlays, or construct my own with a bare ports dir and rsync.
