## Proposal: Metarepo Management

repos, cloning, workspaces, jj, redo

## Problem

The lab repo contains many third-party projects in `oss/`, each cloned and
managed independently. The setup for each project is scattered across
individual Justfiles and clone.do files, with inconsistent patterns:

- **freebsd-src**: colocated clone in `main.jj`, six workspaces, custom build system
- **freebsd-ports**: clone in `repos/`, workspaces in project dir (old pattern)
- **redo-py, redo-rs**: colocated clone via clone.do
- **tailwindcss**: multiple version-tagged workspaces, custom build script
- **jj, please**: clone in `repos/` (old pattern)

Each project re-implements the same basic operations: clone a repo, maybe add
remotes, maybe create workspaces. No unified way to see what repos exist or
where they come from.

Goals:

- Declarative config per project that says "this is the repo, these are the
  remotes, these are the workspaces"
- Single command to set up a project from its config
- Works with jj, not git-centric
- Lightweight, POSIX shell, no heavy dependencies
- Leverage redo's strengths: always runs in the right directory, relative paths
  just work, recursive discovery via symlinks
- Only handle clone + workspace setup. After that, use jj directly.

## Current state

**Standard pattern**: `oss/<project>/default.jj` is a colocated jj+git clone.
Parallel workspaces as `<name>.jj` siblings. This is the pattern going forward
(the old `repos/` indirection is being retired).

**Clone orchestration:**

- Per-project: `clone.do` or Justfile `clone` recipe (inconsistent)
- Root level: `redo oss/clone` discovers `clone.do` files recursively
- dev.sh: creates jj workspaces on demand when starting a dev session

**What varies per project:**

- Clone URL
- Additional remotes (upstream, gerrit, collaborator forks)
- Which workspaces to create
- Post-clone setup (bootstrap scripts)

## Approach: redo as the framework

Use the same pattern as the freebsd-src "magic builder": symlinks to a shared
implementation script, a minimal config file sourced with `. ./config`, and
the filename/directory structure as the API.

### Why redo fits

redo already solves the two hardest problems with scripts:

1. **Path discovery**: redo always runs in the directory where the .do file
   lives. Relative paths just work. No `$PROJECT_ROOT`, no `$(dirname $0)/..`,
   no PATH management.

2. **Recursive discovery**: the existing `subdirs-clone.do` pattern finds all
   `clone.do` files in child directories automatically. Add a new project with
   a `clone.do` → it's included in `redo clone`.

The freebsd-src builder shows how to go further: a single implementation script
handles multiple targets by parsing the symlink name, sourcing a config file,
and dispatching. The same approach works for repo setup.

### Layout

```
share/redo/
  jj-clone.do           # shared: clone a repo from config
  jj-workspace.do       # shared: create a workspace from config

oss/emacs-vertico/
  config                 # project config (URL, remotes)
  clone.do → ../../share/redo/jj-clone.do

oss/freebsd-src/
  config                 # project config (URL, remotes, workspaces)
  clone.do → ../../share/redo/jj-clone.do
  stable-16.jj.do → ../../share/redo/jj-workspace.do
  releng-14.3.jj.do → ../../share/redo/jj-workspace.do
  ...
```

### The .do file IS the config

The shared implementation lives in `share/redo/jj-clone.sh` (a library, not
a .do file). Each project's clone.do sets its config vars and sources the
library:

```sh
#!/bin/sh
# oss/emacs-vertico/clone.do
repo_url="https://github.com/minad/vertico.git"
. "$(jj root)/share/redo/jj-clone.sh"
```

```sh
#!/bin/sh
# oss/freebsd-src/clone.do
repo_url="https://github.com/freebsd/freebsd-src.git"
repo_remotes="
  upstream  https://github.com/freebsd/freebsd-src.git
  github    git@github.com:patmaddox/freebsd-src.git
  gerrit    ssh://localhost:29418/freebsd-src
  srht      git@git.sr.ht:~patmaddox/freebsd-src
"
. "$(jj root)/share/redo/jj-clone.sh"
```

```sh
#!/bin/sh
# oss/freebsd-ports/clone.do
repo_url="git@github.com:patmaddox/freebsd-ports.git"
repo_remotes="
  upstream  https://github.com/freebsd/freebsd-ports.git
  gerrit    ssh://localhost:29418/freebsd-ports
  origin    git@git.sr.ht:~patmaddox/freebsd-ports
  dch       https://git.sr.ht/~dch/ports
"
. "$(jj root)/share/redo/jj-clone.sh"
```

The .do file reads like a config file (just vars and a source line), but it
IS the redo script. No separate config file. No symlink indirection. The
config is right there when you open the file, and redo's recursive discovery
(`subdirs-clone.do`) finds it automatically.

Most projects need only two lines: the URL and the source. Projects with
remotes add a few more. The shared library does all the work.

### jj-clone.sh

The shared implementation, sourced (not symlinked) by clone.do scripts:

```sh
# share/redo/jj-clone.sh
#
# Expects these vars to be set by the caller:
#   repo_url       (required) - git URL to clone
#   repo_remotes   (optional) - newline-separated "name url" pairs
set -eu

if [ -z "${repo_url:-}" ]; then
    echo "error: repo_url not set" >&2
    exit 1
fi

if [ ! -d default.jj ]; then
    jj git clone --colocate "$repo_url" default.jj
fi

if [ -n "${repo_remotes:-}" ]; then
    echo "$repo_remotes" | while read -r name url; do
        [ -z "$name" ] && continue
        jj -R default.jj git remote add "$name" "$url" 2>/dev/null || true
    done
fi
```

### jj-workspace.sh

Same pattern for workspaces. The .do file names the workspace and sources
the library:

```sh
#!/bin/sh
# oss/freebsd-src/stable-16.jj.do
. "$(jj root)/share/redo/jj-workspace.sh"
```

The workspace name comes from $1 (redo's target name):

```sh
# share/redo/jj-workspace.sh
set -eu

redo-ifchange clone   # ensure the repo is cloned first

ws_name="${1%.jj}"
ws_dir="${ws_name}.jj"

if [ ! -d "$ws_dir" ]; then
    jj -R default.jj workspace add --name "$ws_name" "$ws_dir"
fi
```

For workspaces, the .do file really is just the source line - all the config
is derived from the filename. But it's still a real .do file, not a symlink,
so you can add project-specific logic if needed.

### How it works

**Clone a single project:**
```sh
cd oss/emacs-vertico
redo clone
# → clone.do sets repo_url, sources jj-clone.sh, clone happens
```

**Create a workspace:**
```sh
cd oss/freebsd-src
redo stable-16.jj
# → redo-ifchange clone (ensures cloned first)
# → creates workspace "stable-16" from default.jj
```

**Clone everything:**
```sh
redo oss/clone
# → subdirs-clone.do discovers all clone.do files recursively
# → each clone.do sets its own vars and sources the shared library
```

**Add a new project:**
```sh
mkdir oss/emacs-consult
cat > oss/emacs-consult/clone.do <<'EOF'
#!/bin/sh
repo_url="https://github.com/minad/consult.git"
. "$(jj root)/share/redo/jj-clone.sh"
EOF
chmod +x oss/emacs-consult/clone.do
# Done. `redo oss/clone` now includes it.
```

### $(jj root) as workspace-root reference

`$(jj root)` gives every .do script a stable path to the monorepo root,
like bazel's `//`. This is what makes the "set vars, source library" pattern
work - the .do file runs in its own directory (redo's guarantee) and reaches
the shared library via `$(jj root)/share/redo/...`.

It also enables cross-project dependencies:

```sh
#!/bin/sh
# dotfiles/emacs/contrib/vertico.do
redo-ifchange "$(jj root)/oss/emacs-vertico/clone"

# Now we know oss/emacs-vertico/default.jj exists
srcdir="$(jj root)/oss/emacs-vertico/default.jj"
cp "$srcdir"/*.el "$3"
```

This connects the emacs contrib/ workflow to the metarepo cloning. Building
contrib/vertico declares a dependency on the vertico clone being present.
redo's dependency graph spans across project directories via `$(jj root)`.

**When to use which:**
- Relative paths for same-directory references (./config, default.jj)
- `$(jj root)` for shared libraries and cross-project dependencies

### Connection to emacs contrib/

This changes the emacs contrib/ proposal. Instead of a standalone
contrib-update.sh script, contrib/ population can be redo targets with
cross-project dependencies:

```sh
# dotfiles/emacs/contrib/vertico.do
redo-ifchange "$(jj root)/oss/emacs-vertico/clone"
srcdir="$(jj root)/oss/emacs-vertico/default.jj"
cp "$srcdir"/*.el "$3"/
```

But recall the earlier discussion: if oss/emacs-vertico hasn't been cloned,
redo can't know contrib/ is stale. Two modes:

1. **oss/ clone exists**: `redo contrib/vertico` clones if needed (via
   redo-ifchange), copies .el files. Full automation.
2. **oss/ clone doesn't exist**: contrib/vertico/ is already checked in.
   The pkg build uses what's there. No redo needed.

So the redo-based contrib .do scripts are for the "update" workflow (when
you have the clone). The "just build from what's checked in" workflow
doesn't go through redo at all - the pkg.do script just consumes the
committed contrib/ files directly.

### Generated manifests for tooling

The .do scripts are the source of truth for config. But other tools (dev.sh,
status dashboards, CI) need to know what repos exist, where they came from,
and what state they're in. Rather than parsing .do scripts, have redo produce
a manifest as a build output.

The clone .do script writes a manifest entry as a side effect:

```sh
#!/bin/sh
# share/redo/jj-clone.sh (sourced by project .do scripts)
set -eu

if [ ! -d default.jj ]; then
    jj git clone --colocate "$repo_url" default.jj
fi

# ... add remotes ...

# Write manifest entry
commit=$(jj -R default.jj log -r @ --no-graph -T 'commit_id.short(12)')
cat > manifest.json <<EOF
{
  "url": "${repo_url}",
  "commit": "${commit}",
  "path": "$(pwd)/default.jj",
  "remotes": { ... }
}
EOF
```

A top-level target assembles individual manifests into one:

```sh
#!/bin/sh
# oss/manifest.do - aggregate all project manifests
set -eu
printf '{\n'
first=true
for m in */manifest.json; do
    project=$(dirname "$m")
    $first || printf ',\n'
    printf '  "%s": ' "$project"
    cat "$m"
    first=false
done
printf '\n}\n'
```

Now tools can consume `oss/manifest.json`:

- **dev.sh**: read the manifest to list available projects and branches,
  instead of scanning the filesystem with `ls -dt`
- **status tool**: show which projects are cloned, at what commit, how
  far behind upstream
- **emacs contrib/**: read the manifest to know what commit is in contrib/
  (replaces the contrib.manifest file from the emacs proposal - it's now
  just part of the repo-wide manifest)
- **CI**: verify that expected projects exist and are at expected commits

The key inversion: the manifest is an output, not an input. The .do scripts
define the config. The manifest reflects the current state. Tools read the
manifest, never the .do scripts. This keeps the boundary clean - redo owns
the build, tools own the querying.

## Things to think about

**redo targets produce files, not directories.** The clone and workspace
targets create directories as side effects and use `if [ ! -d ... ]` for
idempotency. This isn't pure redo-style file tracking (redo can't `redo-ifchange`
a directory), but it's the same pattern the existing clone.do scripts use
and it works. The `redo-ifchange clone` in jj-workspace.do ensures ordering
without needing file-level dependency tracking. The manifest file gives redo
a real file output to track for the clone target.

**Manifest format.** JSON is shown above because it's easy to consume from
many languages. But it could be plain text, TSV, or anything. The format
should match what the consuming tools want. If most tools are shell scripts,
a simpler format (one line per project, tab-separated fields) might be better
than JSON.

**Workspace lifecycle.** jj-workspace.do creates workspaces, but what about
removing old ones? Workspaces come and go (tailwindcss version tags, release
branches). Creating is automated; removing stays manual (`jj workspace forget`).
The symlinks serve as documentation of which workspaces are expected.

**Post-clone hooks.** Some projects need setup beyond clone + remotes (e.g.,
oss/please needs a bootstrap build). Options:
- A `setup.do` script in the project dir that `redo-ifchange clone` then
  runs project-specific logic.
- A `post_clone` shell snippet in config (like freebsd-src's config vars).
- Keep it separate - the Justfile or other .do scripts handle build/bootstrap.
Probably keep it separate. clone.do is "get the code here." Building is a
different concern.

**Extending the pattern.** The symlink + config + shared implementation pattern
could apply to more than just cloning. For example:
- `fetch.do → ../../share/redo/jj-fetch.do` to pull latest from all remotes
- `all.do` that depends on clone + workspaces + build
But per the goal: keep it minimal. Clone and workspace setup. Use jj directly
after that.

**What about src/ projects?** src/ projects are your own code, not clones.
They probably don't need clone.do at all. If they have remotes (gerrit, github),
those are set up once and don't change. Don't force the pattern where it
doesn't fit.

## Alternatives considered

**myrepos (mr):** VCS-agnostic, declarative INI config, post-checkout hooks.
Available as a FreeBSD package. The closest existing tool for this job.

However: mr is a runner, not a schema. Its config is imperative shell in an
INI wrapper - it doesn't model remotes or workspaces as data. It also doesn't
solve the path problem (you'd still need to figure out where scripts live).
And it doesn't compose with redo's recursive discovery. Using redo directly
is simpler for this repo because redo is already the build system, already
handles discovery, and already runs in the right directory.

**Standalone repo-setup script + repo.conf:** The previous draft of this
proposal. Works, but has the path problem: the script needs to be on PATH
or referenced by absolute/relative path, and config files need to know where
they are relative to the project root. redo eliminates both problems.

**Google repo, vcstool, gita, etc.:** All git-only, no jj support. See
research notes in previous draft.

**Keep current approach (ad-hoc Justfile/clone.do):** Works but inconsistent.
The redo pattern standardizes without adding new tools - it's just more
disciplined use of what's already here.
