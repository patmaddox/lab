## Proposal: Documentation and Search Stack

note taking

## Problem

The lab repo contains complex, interconnected knowledge - image builds, FreeBSD development workflows, emacs configuration, infrastructure setup - spread across multiple projects and formats.
This knowledge is hard to find and easy to forget.
There is no unified way to write, search, and browse documentation across the repo.

Goals:

- Long-form documentation (handbook-style) for complex topics
- Short articles and guides for specific tasks
- Searchable notes (zettelkasten-style atomic notes with linking)
- Personal man pages for quick CLI reference
- Access from emacs, the command line, and a web browser

## Note management: denote

Emacs package for note creation, naming, linking, zettelkasten structure.
Supports org and markdown per-file - choose format based on what the content needs.
File naming convention (`ID--title__keywords.ext`) makes files greppable from CLI without emacs.

## Web rendering: hugo

Already in use for patmaddox.com.
Render docs in reading mode.

## Personal man pages

Write mdoc pages in a custom MANPATH.
Native FreeBSD format, renders with `man` directly.
Access via a wrapper script:

```sh
#!/bin/sh
# bin/pm - personal manual lookup
man -M /home/patmaddox/lab.jj/docs/man "$@"
```

Usage: `pm 7 emacs`, `pm 7 beastie`, etc.

## Lightweight search: pm-nvfind (done)

Small elisp package at `dotfiles/emacs/lisp/pm-nvfind/`.
Chains `rg -l word1 | xargs rg -l word2` for file-level multi-word AND search.
Only dependency is ripgrep.  Optional consult integration for file preview.

Features:
- Named search scopes with configurable default scope
- Iterative query refinement (C-r to edit query, results update)
- Consult file preview during result selection (soft dependency)
- ERT tests

## Full-featured search: NotDeft

Deft rewrite backed by Xapian.
nvALT-style multi-word AND search with live filtering.
More powerful query syntax than pm-nvfind:

- `foo NEAR/5 bar` - proximity (within n words)
- `foo ADJ bar` - proximity, order-preserving
- `"exact phrase"` - phrase match
- `+required -excluded`
- `title:`, `tag:`, `file:`, `ext:`, `path:` - field-specific
- `!time`, `!rank`, `!file` - sort modifiers

**Multi-directory**: `notdeft-directories` (list of dirs, recursive) + `notdeft-sparse-directories` (cherry-pick specific files from other locations).

**Build on FreeBSD**: `pkg install xapian-core tclap && gmake` in the xapian/ subdir.
C++11, no patches needed.

Actively maintained (last commit Feb 2026).
No MELPA package - install via straight.el or manual.

**Open question**: NotDeft's default search is two-stage (query then filter).
Can we write a custom function to provide single-stage nvALT-style search (type words, results update immediately)?
Xapian's implicit AND on bare words should make this straightforward - the query just needs to be passed directly to the Xapian backend on each keystroke.

## Alternatives considered and set aside

- **Xeft** - simpler Xapian search.
  Single directory only, no field prefixes, no note management.
  Xeft author recommends NotDeft for power users.
- **zk** (CLI zettelkasten) - markdown only.
  Good for vim/CLI-first users.
  Redundant with denote for emacs users.
- **deft** - nvALT-style search but single directory, no Xapian, poor scaling.
  NotDeft supersedes it.
- **consult-ripgrep for nvALT-style search** - ripgrep is line-oriented, can't do file-level multi-word AND.
  Still useful for targeted line-level searches.
