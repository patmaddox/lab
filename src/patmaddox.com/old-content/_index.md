+++
template = "index.html"
+++

# Home

<center>
<form action='$ROOT/docsrch' method='GET'>
<input type="text" name="s" size="40" autofocus>
<input type="submit" value="Search">
</form>
</center>

This is my [monorepo](why-monorepo.md).

## Writing

- [First steps in programming FreeBSD: Reading process information](programming-freebsd-reading-process-information/)
- [sh: Relative shell script includes with realpath on FreeBSD](sh-relative-shell-script-includes-with-realpath-on-freebsd/)
- [Lenovo T14 Gen 2 AMD - a fine laptop for FreeBSD (with a wifi caveat)](lenovo-t14-gen2-amd-a-fine-laptop-for-freebsd.md)

## Primary Purpose

Iterate my way to a personal computing setup that I love, and that grows with my needs and wants.

## What I'm up to

The simplest way to see what I'm up to is to look at the [timeline](/timeline). That's everything going on in this repo.

- [trunk](/timeline?r=trunk) shows what I consider to be ready for the world to see.
- [branches](/brlist) show the currently active lines of development. They reflect what I'm actually doing on a day-to-day basis.
- [tags](/taglist) show noteworthy commits, or commits grouped around a particular activity.
- [open source contributions](open-source-contributions/) - contributions to upstream projects

Here are the specific branches or directories that are primarily of interest to me at the moment:

- [build-ports](/timeline?r=build-ports) - The [FreeBSD Ports framework](https://www.freebsd.org/ports/) is really cool.
  I am learning to maintain existing ports, and add new ones, so that I can easily run the software I want.
  This branch includes my efforts to increase my effectiveness in working with ports.
- [ffi](/timeline?r=ffi) - My explorations of how different languages call C libraries, so that I can write command-line utilities for FreeBSD.
- [drafts](/dir?ci=trunk&name=drafts) - I have always enjoyed writing, though I haven't published much in the last several years.
  I want to get back into it.
  This branch includes my in-progress writing.
- [bhyve](/timeline?r=bhyve) - FreeBSD includes a hypervisor called [bhyve](https://man.freebsd.org/cgi/man.cgi?bhyve).
  I have only briefly experimented with it, I'm still learning how to use it.
  I want to use it primarily for FreeBSD development - I need a VM to run development branches so I don't screw up my daily driver.
  I also plan to experiment with running Linux VMs, because my work relies on some Linux-only tools (e.g. Docker, fly.io)

## Other considerations

Working with this repo feels a bit like [Jerry Weinberg's Fieldstone Method](https://geraldmweinberg.com/Site/On_Writing.html), applied to code.
I start things in [`experiments/`](experiments.md), and grow them as I see fit.
When I've built up something solid, I can incocorporate it into my over all system.

This repo is my home dir on a FreeBSD system.
I had considered trying to make it portable with MacOS.
I ended up getting a FreeBSD laptop instead, and I'm happier for it.

## Links

- [Inbox](inbox.md)
- [Fossil Wishlist](fossil_wishlist.md)
- [Repo Wishlist](repo-wishlist.md)
- [The Scrap Heap](scrapheap.md)
- [TODO](todo.md)
- [Wishlist vs TODO](wishlist-vs-todo.md)
- [What I like about Fossil](what-i-like-about-fossil.md)
- [Why a monorepo?](why-monorepo.md)

## Subprojects

### ports

- [ ] use an overlay dir instead of git worktrees
  - I had stopped using it because of some problem with poudriere.
    I forget what it was.
    Git worktrees are kind of a pain to maintain though.
    I can either go back to poudriere overlays, or construct my own with a bare ports dir and rsync.
