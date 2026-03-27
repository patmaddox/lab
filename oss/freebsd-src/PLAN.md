# freebsd-src Plan

Develop FreeBSD source and build packages for personal infrastructure.

## Goals

1. Develop freebsd-src and contribute patches upstream
2. Build multiple versions (release, stable, current, personal branches)
   as pkgbase packages for deployment to hosts and VMs

## Architecture

Two distinct loops — dev and release — sharing the same build scripts
but differing in where source comes from.

### Dev loop (fast iteration)

Edit on beastie (workstation) → NFS share to dev VM on andre →
build dirty tree → run tests → iterate.

The dev VM runs CURRENT so tests match the built kernel. NFS means
zero-friction editing — save in emacs, build immediately.

### Release loop (clean builds)

Edit on beastie → commit → jj git push → build jail on andre
fetches bookmarks → builds from clean commits → pkgbase packages →
serve via HTTP → deploy to hosts.

The build jail runs on RELEASE (any version can cross-build). It
never sees a dirty tree — only pushed bookmarks.

```
beastie (workstation)              andre (VM host, RELEASE)
  └── edit in emacs                  ├── dev VM (CURRENT kernel)
  │     │                            │    ├── NFS mount of source
  │     └── NFS ─────────────────────┤    ├── build dirty tree
  │                                  │    └── run tests
  └── jj git push ──────────────────→├── build jail
                                     │    ├── fetch bookmarks
                                     │    ├── redo <config>.<target>
                                     │    └── serve pkgbase packages
                                     ├── poudriere VM (ports packages)
                                     └── test VM (on-demand validation)
```

## Repository layout

- `default.jj/` — single jj repo tracking all branches
- `config` — maps config names to bookmarks and kernel configs
- `do.freebsd-src` — redo build script (symlinked per config+target)
- `scripts/build.sh` — the actual build logic
- `_build/<config>/` — build outputs (src checkout, obj, pkgbase)
- `src.conf` — shared make options
- `ccache.conf` — ccache configuration

## Branch model (jj mega-merge)

```
main (upstream HEAD)
stable/stabweek (monthly stabilization tag)
├── patmaddox/branch1 (feature/fix, has GH PR or Phab review)
├── patmaddox/branch2
├── patmaddox/branch3
└── pm/stable  ← merge(stabweek, branch1..3)  "ready to contribute"
    ├── wip-branch4 (not yet submitted)
    └── pm/main  ← merge(pm/stable, main, wip4)  "daily driver"
```

- **patmaddox/* branches**: individual patches, each with an upstream
  review (GitHub PR or Phabricator)
- **pm/stable**: merge of stabweek + all reviewed patches. Everything
  here should be submitted upstream.
- **pm/main**: merge of pm/stable + upstream main + WIP work. The
  "use everything I have" build.

### Useful revsets

Add to the repo config (`jj config path --repo` from within main.jj):

```toml
[revset-aliases]
"pm()" = "pm/stable | pm/main"
"my-branches()" = "bookmarks(glob:'patmaddox/*')"
"my-work()" = "my-branches() | pm()"
"overview()" = "my-work() | stable/stabweek | main | roots(my-branches())"
```

- `jj log -r 'overview()'` — see the whole picture
- `jj log -r 'my-branches()'` — just your patches
- `jj log -r 'pm()'` — the merge commits

### Rebase day procedure

When upstream moves (new stabweek, main advances):

1. `jj git fetch`
2. Update `stable/stabweek` bookmark to new stabilization commit
3. Rebase each `patmaddox/*` branch onto new stabweek
4. Recreate `pm/stable` as merge of stabweek + all patmaddox branches
5. Recreate `pm/main` as merge of pm/stable + main + WIP branches
6. `jj git push` to update remotes

### Upstream contribution

- Primary: GitHub pull requests (simple patches)
- Secondary: Phabricator reviews (when needed)
- Each `patmaddox/*` branch = one logical change = one review
- Bookmark naming: `patmaddox/<jj-change-id>` (auto-generated)

## Build system (redo)

The build system uses redo. Each build target is a symlink to
`do.freebsd-src`:

```sh
ln -s do.freebsd-src current.buildworld.do
ln -s do.freebsd-src current.buildkernel.do
ln -s do.freebsd-src current.pkgbase.do
```

The script parses the symlink name to derive config + target, reads
`./config` for the tree and kernel, and calls `scripts/build.sh`.

### Building

```sh
redo current.buildworld    # build world for CURRENT
redo current.buildkernel   # build kernel for CURRENT
redo current.pkgbase       # build pkgbase packages for CURRENT
redo 150.pkgbase           # build pkgbase for releng/15.0
```

### Config format

```sh
conf_<name>_bookmark=<jj bookmark>
conf_<name>_kernel=<KERNCONF>
```

## Implementation phases

### Phase 1: Document & navigate
- [ ] Add jj revset aliases to config
- [ ] Rename main.jj → default.jj

### Phase 2: Consolidate to bookmark-based config
- [ ] Update `config` to reference bookmarks instead of worktree dirs
- [ ] Update `do.freebsd-src` / `build.sh` to resolve bookmark → SHA
- [ ] Remove old worktree directories (optional, not urgent)
- [ ] Remove ninja/Justfile remnants (rewrite Justfile as redo wrappers)

### Phase 3: Remote build (release loop)
- [ ] Set up build jail on andre
- [ ] Set up jj/git remote between beastie and build jail
- [ ] Write `build-remote` wrapper: push → ssh → redo
- [ ] Verify redo dependency tracking works across pushes

### Phase 4: Dev loop
- [ ] Set up dev VM on andre (CURRENT kernel)
- [ ] NFS mount source from beastie
- [ ] Verify build + test cycle works from NFS mount
- [ ] Script for "build and run tests" from beastie

### Phase 5: Package serving
- [ ] Serve pkgbase from build jail (nginx or file://)
- [ ] Per-config repo URLs (current, 150, pm, stabweek)
- [ ] ZFS snapshots of build outputs for atomic publishing
- [ ] Optionally: `zfs send` to dedicated serving jail

### Phase 6: VM test loop
- [ ] Script to create test VM from pkgbase packages
- [ ] Smoke tests (boot, SSH, services)
- [ ] Integrate as redo target (`current.tested`)
- [ ] Tag passing builds for deployment

### Phase 7: Host deployment
- [ ] Per-host shell script (future shanty integration)
- [ ] `bectl create` + `pkg install` from pkgbase repo
- [ ] App packages from poudriere
- [ ] Host-specific config
- [ ] Activate boot environment + reboot
