# ccache across multiple source trees

## Problem

FreeBSD's `src.conf(5)` suggests:

    CCACHE_BASEDIR='${SRCTOP:H}' MAKEOBJDIRPREFIX='${SRCTOP:H}/obj'

This works for a single tree, but not for multiple named trees
(e.g. `current/` and `pm-current/`). `MAKEOBJDIRPREFIX` concatenates
the full source path into the obj hierarchy:

    OBJROOT = MAKEOBJDIRPREFIX + SRCTOP
    /var/tmp/obj/var/tmp/freebsd-src/current/...

After `base_dir` normalization, the tree name survives in relative
paths (`./current/...` vs `./pm-current/...`), so every compiler
flag that references source or obj hashes differently. Result: 0%
cache hits.

## Fix

Use `OBJROOT` instead of `MAKEOBJDIRPREFIX` to place obj under the
source tree root. Set `CCACHE_BASEDIR` to `${SRCTOP}` (not
`${SRCTOP:H}`).

    OBJROOT=${src}/obj/
    CCACHE_BASEDIR='${SRCTOP}'

With obj under the source root, both source and obj paths fall under
`CCACHE_BASEDIR` and normalize to tree-independent relative paths:

    Source: ./sys/kern/foo.c          (same for all trees)
    Obj:    ./obj/amd64.amd64/...     (same for all trees)
    -ffile-prefix-map: .=/usr/src     (same for all trees)

`bsd.compiler.mk` expands and exports `CCACHE_BASEDIR` via:

    .for var in CCACHE_LOGFILE CCACHE_BASEDIR
    .if defined(${var})
    ${var}:=    ${${var}}
    .export     ${var}
    .endif
    .endfor

So passing `'${SRCTOP}'` (single-quoted, unexpanded by the shell)
lets bmake expand it to the actual source path before exporting to
ccache.

## ccache 3 vs 4

ccache 3 hashes the absolute CWD without applying `base_dir`
normalization, so `hash_dir = false` is required. ccache 4 normalizes
the CWD through `base_dir` before hashing, so the default
`hash_dir = true` works.

## References

- `src.conf(5)` - one-line example of CCACHE_BASEDIR + MAKEOBJDIRPREFIX
- `share/mk/bsd.compiler.mk` - ccache integration, BASEDIR expansion
- `share/mk/src.sys.obj.mk` - OBJROOT/OBJTOP/MAKEOBJDIR computation
- `share/mk/bsd.debug.mk` - `-ffile-prefix-map` for reproducible builds
- ccache manual, base_dir section - https://ccache.dev/manual/latest.html
- Justin Lebar, "Set CCACHE_BASEDIR to share object files between trees" (2011)
- Muxup, "ccache for LLVM builds across multiple directories" (2025)
