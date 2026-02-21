## Proposal: Emacs Package Management in the Monorepo

emacs, packages, self-contained

## Problem

Emacs packages currently come from FreeBSD ports.
This works - no package manager downloads on startup, versions are stable - but it has limitations:

- **Not self-contained**: the repo depends on ports having the right packages at the right versions.
  A fresh machine needs `pkg install` to get emacs working. The repo can't stand alone.
- **Can't hack on packages**: ports installs to `/usr/local/share/emacs/`. To modify a package
  (fix a bug, add a feature, contribute upstream), there's no clean workflow.
- **Can't publish own packages**: custom packages in `lisp/` (pm-nvfind, pm-nirvana, freebsd-style-ts)
  are embedded in the emacs config. To publish pm-nvfind as a standalone repo, or submit it to MELPA,
  the code needs to live somewhere it can be extracted and pushed independently.

Goals:

- Make the repo as self-contained as possible (emacs starts without downloading)
- Clone a package repo, modify it, use it immediately in emacs
- Publish own packages as separate git repos / contribute upstream to third party packages
- Keep the simplicity of the current setup (no complex package manager state)

## Current state

Packages from ports: vertico, consult, marginalia, orderless, prescient, perspective,
eat, vterm, markdown-mode, tree-sitter grammars, org (built-in).

Custom packages in `dotfiles/emacs/lisp/`: pm-nvfind, pm-nirvana, freebsd-style-ts.

init.el uses `require` directly - no use-package, no lazy loading, no package.el.

The emacs config is built into a FreeBSD `.pkg` via redo and installed to `~/.emacs.d/`.

## Proposed approach: contrib/ as a pinned staging area

Three-layer system: `oss/` for development, `contrib/` as checked-in snapshot, `.pkg` for deployment.

### Layout

```
oss/
  emacs-vertico/       # full git clone, for hacking
  emacs-notdeft/       # full git clone, for hacking
  ...
dotfiles/emacs/
  init.el
  lisp/                # custom packages (as today)
  contrib/             # checked-in snapshots of third-party packages
    vertico/
    consult/
    marginalia/
    orderless/
    prescient/
    perspective/
    markdown-mode/
    notdeft/
    ...
  contrib.manifest     # records what's in contrib/ and where it came from
```

### Workflow

**Normal use (no clones needed):**

```
contrib/ exists in repo  →  pkg build includes it  →  pkg install  →  emacs works
```

The repo is self-contained. A fresh clone has everything needed to build the pkg
and start emacs. No network fetch, no package manager, no ports dependency for
pure elisp packages.

**Updating a package (manual subtree-pull without subtrees):**

```
1. clone/update in oss/     redo oss/emacs-vertico  (or git pull if already cloned)
2. (optional) hack on it    edit files in oss/emacs-vertico/
3. flatten into contrib/    sh contrib-update.sh vertico
4. commit contrib/          jj commit
5. build pkg as usual       just pkg  (in dotfiles/emacs/)
```

This is conceptually the same as `git subtree pull` - take upstream changes and
merge them into a subdirectory of the monorepo. But instead of subtree merge
machinery, you just copy the files. The history linkage lives in contrib.manifest
(recording the source repo and commit), not in VCS metadata.

Step 1 is only needed when you want to pull in changes. Once contrib/ is populated
and committed, the oss/ clone can be deleted and everything still works.

**Hacking on a package:**

For active development, point load-path at the oss/ clone so changes take effect
immediately without copying to contrib/ on every edit:

```elisp
;; Development overrides - shadow contrib/ versions when present
(dolist (dir '("~/lab.jj/oss/emacs-notdeft"))
  (when (file-directory-p dir)
    (add-to-list 'load-path dir)))
```

When done hacking, copy the result back to contrib/ and commit.

### contrib.manifest

Track provenance so you know what's in contrib/ and can update it:

```
# package        git-url                                          commit
vertico          https://github.com/minad/vertico.git             abc1234
consult          https://github.com/minad/consult.git             def5678
marginalia       https://github.com/minad/marginalia.git          789abcd
notdeft          https://github.com/hasu/notdeft.git              012ef34
```

This is informational - it tells you where to clone from and what commit is
currently in contrib/. It's not consumed by build tooling automatically
(though it could be, to automate the clone + copy step).

### Build integration

init.el adds contrib/ to load-path:

```elisp
;; Third-party packages (checked into repo)
(dolist (dir (directory-files (expand-file-name "contrib" user-emacs-directory) t "^[^.]"))
  (when (file-directory-p dir)
    (add-to-list 'load-path dir)))
```

The pkg build (patmaddox-emacs.pkg.do) extends the file list to include contrib/:

```sh
elfiles="init.el $(jj file list lisp) $(jj file list contrib)"
```

### Populating contrib/

A simple shell script, not redo. Populating contrib/ is a deliberate manual action
(like `git subtree pull`), not an automatic build dependency. redo's dependency
tracking doesn't help here - if the oss/ clone doesn't exist, there are no source
files to track, and redo has no way to know contrib/ is stale.

```sh
#!/bin/sh
# contrib-update.sh - copy package files from oss/ clone into contrib/
set -eu

pkg="$1"
srcdir="$HOME/lab.jj/oss/emacs-${pkg}"

if [ ! -d "$srcdir" ]; then
    echo "error: $srcdir not found. Clone it first." >&2
    exit 1
fi

destdir="$HOME/lab.jj/dotfiles/emacs/contrib/${pkg}"
rm -rf "$destdir"
mkdir -p "$destdir"
cp "$srcdir"/*.el "$destdir"/

# Record provenance
commit=$(git -C "$srcdir" rev-parse HEAD)
origin=$(git -C "$srcdir" remote get-url origin 2>/dev/null || echo "unknown")
echo "Updated ${pkg}: ${origin} ${commit}"
```

Packages that need more than a flat .el copy (e.g., vertico has extensions in a
subdirectory, NotDeft has a Xapian component) would get package-specific logic -
either a case statement in the script or per-package scripts.

The pkg build (redo) then just consumes whatever is in contrib/. It does
`redo-ifchange` on the contrib/ .el files, which are always present in the repo.
redo handles the pkg build; the manual script handles populating contrib/.

### What about own packages (lisp/ → oss/ or src/)?

The same pattern works in reverse for publishing custom packages:

- Move pm-nvfind from `lisp/` to `src/pm-nvfind/` (or `oss/pm-nvfind/`)
  as a standalone repo with its own README, tests, license.
- In `contrib/`, add a `pm-nvfind/` snapshot built from `src/pm-nvfind/`.
- Or: keep it in `lisp/` for now. It already works. Move it when there's
  an actual need to publish (MELPA submission, someone else wants to use it).

The contrib/ pattern handles both directions: pulling in third-party code
and staging your own code for the pkg build.

## Tradeoffs

**Pros:**

- Self-contained. Fresh clone → build pkg → emacs works. No network needed.
- Simple mental model: contrib/ is what you ship, oss/ is where you hack.
- Fits existing monorepo patterns (oss/ for clones, redo for builds).
- No emacs package manager. No runtime state. Just files.
- Incremental: start with one package in contrib/, migrate from ports gradually.
- The oss/ clone is optional and temporary - only needed during active development.

**Cons:**

- Duplicated files: the same .el files exist in both oss/ and contrib/ while
  hacking. (But oss/ is temporary and not checked in.)
- Manual update workflow: clone, copy, commit. No `straight-pull` equivalent.
  Could be automated with redo, but it's still more steps than a package manager.
- contrib/ is a snapshot, not a live repo. You lose git blame/history for the
  vendored files. (Mitigated by contrib.manifest pointing to the source.)
- Repo size grows. Though pure elisp packages are small - the full set is
  probably under 2MB.

## Things to think about

**What goes in contrib/ vs. stays in ports?** Packages with compiled C
components (vterm, tree-sitter grammars) should probably stay as ports.
contrib/ is for pure elisp. Draw the line at: if it's just .el files, it
can go in contrib/. If it needs a C compiler, keep it in ports.

**Native compilation:** Ports-installed packages may come byte-compiled or
native-compiled. contrib/ ships source. Emacs will JIT native-compile on
first load (if built with native-comp support), or you could add a
byte-compile step to the pkg build.

**Autoloads:** Some packages ship generated autoload files. The simple "copy .el
files" approach may miss these. Options: generate autoloads in the .do script
(`emacs --batch -f batch-update-autoloads`), or just `require` everything
explicitly in init.el (which is what you do now).

**How many packages to start with?** NotDeft is the obvious first candidate -
it's not in ports, so you need a non-ports install path regardless. Migrating
one package validates the workflow before committing to migrating everything.

**Load-path ordering for development:** When hacking in oss/, the oss/ dir
needs to be earlier in load-path than contrib/ to shadow it. The `add-to-list`
with default prepend behavior handles this naturally, but be aware of it.

**jj file tracking:** contrib/ files are checked into the jj repo. Since
they're snapshots (not live repos), there's no nested `.jj` or `.git` directory
issue - it's just .el files in the monorepo.

## Alternatives considered

**straight.el / elpaca:** Purpose-built emacs package managers. Handle autoloads,
byte-compilation, dependencies, lockfiles. But: download on first startup,
complex internals, fights the "no emacs package manager" philosophy. The contrib/
approach gets the same self-containment without runtime complexity.

**Git subtrees in the monorepo:** The contrib/ approach is essentially a manual
subtree workflow - same operation (upstream → subdirectory), just without VCS
merge tracking. The tradeoff: you lose `git subtree pull` automation, but you
gain independence from VCS features (jj's subtree support is immature) and the
workflow is transparent - it's just copying files and committing.

**Just point load-path at oss/:** Simpler but not self-contained. Every machine
needs all the clones. A missing clone breaks startup.

**Ports for everything:** Status quo. Self-contained at the system level but
not at the repo level. No development workflow for hacking on packages.
