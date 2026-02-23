## Proposal: Remote Provisioning

provisioning, deployment, boot environments, FreeBSD

## Problem

Deploying boot environments and config files to machines currently involves
two different systems that overlap awkwardly:

- **new-be** (src/new-be): POSIX shell script for creating boot environments.
  Has local and remote modes (libnewbe.sh vs libnewbe-remote.sh). The remote
  mode inlines shell functions into ssh heredocs to execute on the remote host.
  Tightly coupled to a specific workflow (create BE, install base, config, packages,
  sync data). Hard to run individual steps.

- **ansible** (infra/common/deploy.yml): A full playbook that imports a BE image,
  extracts config files, syncs users/groups, copies data files. Has local vs remote
  logic throughout (delegating to localhost, conditional file copies). Requires
  ansible installed on the control machine. 80+ lines of YAML for what is
  fundamentally: copy files, run commands, take snapshots.

Both systems solve the same core problem: execute a sequence of privileged
operations on a target machine, either locally or via SSH. The difference is
just the transport.

**Machines:**
- **beastie**: local workstation (always local execution)
- **gulliver**: local server (can be local or remote)
- **andre**: remote server (always remote)
- **patmaddox.com**: remote server (always remote)

Goals:

- Single tool that runs the same operations locally or remotely
- POSIX shell, no dependencies on the remote machine beyond base FreeBSD
- No ansible or other heavy tool on the control machine
- Idempotent steps with ZFS snapshots as checkpoints
- Can run individual steps, not just the full sequence
- Config files and scripts live in the repo (infra/hosts/<hostname>/)

## Current workflow

The deploy process has these logical steps:

1. **Import BE image**: `bectl import <name> < image.zfs`
2. **Mount BE**: `bectl mount <name> /tmp/be-<name>`
3. **Extract config files**: `tar -C dist -c @dist.mtree | tar -C <mount> -x`
4. **Set timezone**: `tzsetup -C <mount> <timezone>`
5. **Sync users/groups**: `sync-pw /etc <mount>/etc u <user>` (for each user/group)
6. **Copy data files**: `tar -C / -c @data.mtree | tar -C <mount> -x`
7. **Snapshot after each step**: `zfs snapshot zroot/ROOT/<name>@<step>`
8. **Unmount**: `bectl umount <name>`

Each step is a simple shell command. The complexity is in: running it on the
right machine, making it idempotent (skip if snapshot exists), and getting
files to the remote host.

## Existing tools researched

### drist (JohnKaul fork)

https://github.com/JohnKaul/drist

The closest fit. A single POSIX shell script. BSD origins (original by Solene
Rapenne of OpenBSD). The JohnKaul fork replaced rsync with tar pipes over SSH.

**How it works:**
- Filesystem-as-manifest: `files/` tree mirrors remote filesystem.
  `files/etc/rc.conf` → remote `/etc/rc.conf`. No DSL, no config format.
- Scripts executed on target: `script` and `script-hostname` files.
- File transfer: `tar cf - -C files . | ssh host 'tar xf - -C /tmp/staging'`
- Host targeting via filename suffix: `files-beastie/`, `script-andre`.

**Dependencies:** sh, ssh, tar. Nothing else. Control and remote.

**Strengths:** Truly minimal. The tar pipe is the core mechanism, not an
afterthought. Supports doas natively (`-e` flag). Filesystem conventions
mean no config format to learn.

**Limitations:**
- Fixed execution model (files, then absent, then scripts). Can't interleave
  "copy files, run command, copy more files, run another command."
- No concept of stdin streaming (can't pipe a BE image through).
- File destination is relative to $HOME or /, not flexible.
- No built-in idempotency beyond "files are replaced, scripts re-run."

### cdist

https://www.cdi.st/

A real configuration management system. Push-based, SSH transport.

**How it works:**
- "Types" are directories with a fixed structure: explorers (gather facts
  on target), manifests (declare intent locally), gencode-local/gencode-remote
  (produce shell commands to execute).
- Explorers run on target, output facts. Manifests read facts, decide what
  to do. Gencode produces the actual commands.
- Types compose: a manifest can invoke other types.
- Transport abstracted via `__remote_exec` / `__remote_copy` (pluggable).

**Dependencies:** Python 3.5+ on control. Only sh + sshd on remote.

**Strengths:**
- Clean three-phase architecture: gather facts → decide → act.
- Types are composable and reusable.
- Filesystem-as-database for parameters (just files in directories).
- Optional tar archiving (`-R` flag) to bundle transfers.
- Excellent FreeBSD support (wiki page, pkg types).

**Limitations:**
- Python dependency on control. Non-trivial codebase.
- Many SSH round-trips by default (copy explorers, run, read output,
  copy gencode, run). Archiving mode helps but adds complexity.
- More system than tool. Designed for managing fleet state, not just
  "run these commands on that machine."

**Ideas worth stealing:**
- The explorer concept: small scripts that gather facts on the target
  before deciding what to do. Cleaner than ad-hoc conditionals.
- Filesystem-as-database for parameters.
- Pluggable transport (`__remote_exec` / `__remote_copy`).

### sake

https://github.com/alajmo/sake

A Go task runner for local and remote hosts.

**How it works:**
- YAML config defines servers and tasks.
- Tasks have a `cmd` (shell commands) and `local: true/false`.
- SSH via Go's crypto/ssh library (not shelling out to ssh).
- No built-in file transfer. You define upload tasks using rsync.

**Dependencies:** Single Go binary on control. Only sshd on remote.

**Strengths:**
- `local: true` flag is a clean way to mark "run this here, not there."
- Server environment variables (`$S_HOST`, `$S_NAME`) injected into tasks.
- Task composition with per-task overrides.

**Limitations:**
- YAML config. Go binary dependency.
- No file transfer built in.
- No tar pipe pattern.

### remotely

https://github.com/markasoftware/remotely

A bash library (~200 lines) for remote execution.

**How it works:**
- Source `remotely.sh` in your deploy script.
- `remotely <command>` runs on target with proper argument escaping.
- `remotely_no_escape <command>` for pipes and redirects.
- Persistent SSH control socket for connection reuse.
- `upload` function uses rsync with filesystem mirroring convention.
- m4 templating for config file generation.

**Dependencies:** bash, rsync, m4 on control. rsync on remote.

**Strengths:**
- The argument escaping approach solves SSH word-splitting correctly.
  `remotely` and `remotely_no_escape` is a clean split.
- Persistent SSH socket.
- Convention-based file mirroring (`files/` mirrors remote filesystem).

**Limitations:**
- Requires bash, not POSIX sh.
- rsync dependency on both sides.
- m4 is unusual.

### rset (bonus find)

http://eradman.com/talks/minimalist_scripted_configuration/

Worth investigating separately. C program, uses tar pipes, runs on FreeBSD.
Bundles `rinstall(1)` which can print diffs, set ownership/mode, and returns
meaningful exit codes (0 only when something changed). That "did anything
change?" signal enables conditional service restarts without ansible-style
handlers.

## The hard problem: three kinds of operations

The real challenge isn't "run a command remotely" - that's just SSH. It's
that provisioning involves three distinct kinds of operations:

1. **Remote-only**: run a command on the target.
   `zfs snapshot zroot/ROOT/be@config`

2. **Local-only**: run a command on the control machine.
   `ninja -C ... build-be` (build the image locally)

3. **Combined**: local process pipes to remote process.
   `tar -C dist -cf - @dist.mtree | ssh host 'doas tar -C /mnt -xf -'`
   `cat image.zfs | ssh host 'doas bectl import be-name'`

drist handles #1 and parts of #3 (file copy). But it can't do arbitrary
stdin streaming (#3 with BE images) or interleave local and remote steps.
The heredoc approach in new-be handles #3 but is ugly. ansible handles all
three but with YAML and Python overhead.

## Approach: shanty - a stanza-based provisioning framework

A POSIX shell framework where a deploy script (a "shanty") is composed of
ordered steps ("stanzas"), each with up to four phases that make the
control/target boundary explicit. Inspired by ATF's test-case-as-function
model.

### Naming

- **shanty** (command) - the driver that runs a `.shanty` file
- **.shanty** (file) - the deploy script (the whole song)
- **stanza** - a step (one unit of work)
- **here** - runs on the control machine
- **there** - runs on the target machine
- **stream** - pipes data from here to there's stdin
- **copy** - copies files from here to there

### Stanza lifecycle

Each stanza can have up to four phases:

```
check    → runs there. Return 0 = already done, skip this stanza.
here     → runs here. Prepare data locally (build tarball, stage files).
stream/copy → moves data from here to there.
there    → runs there. Execute the actual operation.
```

All phases are optional. Most stanzas only need one or two.

### Convention over configuration

The framework detects which phases exist by checking for functions with
conventional suffixes. No tags or declarations needed beyond the stanza
name:

- `<name>__check` → runs on target; skip stanza if returns 0
- `<name>__here` → runs locally (prepare data, build tarballs)
- `<name>__stream` → writes to stdout, piped to `there`'s stdin
- `<name>__copy` → copies files to target filesystem, then runs `there`
- `<name>__there` → runs on target (the actual operation)

The double underscore (`__`) separates the stanza name from the phase,
making the boundary unambiguous even when stanza names contain underscores.

`shanty_init` just declares stanza ordering:

```sh
shanty_init() {
    shanty_stanza import_be
    shanty_stanza mount_be
    shanty_stanza extract_config
    shanty_stanza set_timezone
    shanty_stanza sync_users
    shanty_stanza copy_data
    shanty_stanza umount_be
}
```

The framework uses `type` to detect which functions exist and wires
them together accordingly. Define an `import_be__stream` function and
the framework knows to pipe its stdout into `import_be__there`'s stdin.

### A reusable library

Common stanzas live in a library file (`.subr`). Multiple shanties can
source the same library.

```sh
# infra/lib/shanty-be.subr - reusable BE stanzas

import_be__check() {
	bectl list | grep -q "^${be}"
}

import_be__stream() {
	cat "$image_path"
}

import_be__there() {
	bectl import "$be"
}

mount_be__there() {
	bectl mount "$be" "$mnt"
}

extract_config__check() {
	zfs list -t snapshot "${dataset}@config" >/dev/null 2>&1
}

extract_config__stream() {
	tar -C dist -cf - @dist.mtree
}

extract_config__there() {
	tar -C "$mnt" -xf -
	zfs snapshot "${dataset}@config"
}

umount_be__there() {
	bectl umount "$be"
}
```

### A full shanty

The `.shanty` file is a bag of functions and config. The `shanty`
command drives it: `shanty beastie.shanty`

```sh
# infra/hosts/beastie/beastie.shanty

shanty_lib "shanty-be" "$(jj root)/infra/lib/shanty-be.subr"
shanty_target "$host"
shanty_vars be mnt dataset users groups timezone

. ./config

be="${host}-${userland}-${version}"
mnt="/tmp/be-${be}"
dataset="zroot/ROOT/${be}"

shanty_init() {
	shanty_stanza import_be
	shanty_stanza mount_be
	shanty_stanza extract_config
	shanty_stanza set_timezone
	shanty_stanza sync_users
	shanty_stanza copy_data
	shanty_stanza umount_be
}

# --- host-specific stanzas ---

set_timezone__there() {
	tzsetup -C "$mnt" "$timezone"
}

sync_users__copy() {
	shanty_copy_file "$(jj root)/src/sync-pw/sync-pw" /tmp/sync-pw
}

sync_users__there() {
	for u in $users; do
		/tmp/sync-pw /etc "${mnt}/etc" u "$u"
	done
	for g in $groups; do
		/tmp/sync-pw /etc "${mnt}/etc" g "$g"
	done
	rm /tmp/sync-pw
	zfs snapshot "${dataset}@users"
}

copy_data__check() {
	zfs list -t snapshot "${dataset}@data" >/dev/null 2>&1
}

copy_data__stream() {
	tar -C dist -cf - @data.mtree
}

copy_data__there() {
	tar -C "$mnt" -xf -
	zfs snapshot "${dataset}@data"
}
```

The library provides `import_be`, `mount_be`, `extract_config`, and
`umount_be` stanzas. The shanty defines host-specific stanzas
(`set_timezone`, `sync_users`, `copy_data`) and controls the ordering.

### How remote execution works

At startup, the `shanty` command uploads all files to a temp directory
on the remote:

```
/tmp/shanty.<pid>/
    shim.sh
    vars.sh
    lib/shanty-be.subr
    beastie.shanty
```

`vars.sh` contains the serialized variables (`be='value'; mnt='value'; ...`).

Each `_there` or `_check` call is then a simple SSH command:

```sh
ssh host "doas sh -c '
    . /tmp/shanty.xxx/shim.sh
    . /tmp/shanty.xxx/vars.sh
    . /tmp/shanty.xxx/lib/shanty-be.subr
    . /tmp/shanty.xxx/beastie.shanty
    mount_be__there
'"
```

The remote sources the vars, then the libs in order, then the `.shanty`
file. All function definitions get loaded. The last line calls the one
we need. No sed extraction. No heredocs. No `typeset -f`.

On the remote, `shanty_lib`, `shanty_target`, `shanty_vars`, and
`shanty_stanza` are no-ops (defined by the remote-side shim installed
alongside the files). They execute harmlessly when the `.shanty` file
is sourced - the local paths don't need to resolve because the file
contents are already on disk.

Since the files persist on the remote for the duration of the run,
each `_there` call is just an SSH command - no re-uploading. Cleanup
removes the temp directory when the shanty finishes.

This also makes `--stanza` trivial: the files are already there, just
call the function.

### Variable passing

```sh
shanty_vars be mnt dataset users groups timezone
```

The framework serializes declared variables into `vars.sh` on the
remote. Sourced before anything else, so by the time the `.shanty`
file is sourced the variables are already set. Local execution just
runs in the same shell so variables are already available.

### The shanty command

```sh
#!/bin/sh
# shanty - run a .shanty file
set -eu

_shanty_file="$1"; shift
_shanty_host=""
_shanty_local=""
_shanty_stanzas=""
_shanty_varlist=""
_shanty_libs=""
_shanty_lib_names=""
_shanty_remotedir=""

shanty_target() {
	_shanty_host="$1"
	if [ "$(hostname -s)" = "$_shanty_host" ]; then
		_shanty_local="yes"
	else
		_shanty_local=""
	fi
}

shanty_vars() {
	_shanty_varlist="$*"
}

shanty_lib() {
	name="$1"; path="$2"
	. "$path"
	_shanty_libs="${_shanty_libs} ${name}:${path}"
	_shanty_lib_names="${_shanty_lib_names} ${name}"
}

shanty_stanza() {
	_shanty_stanzas="${_shanty_stanzas} $1"
}

shanty_copy_file() {
	src="$1"
	dest="$2"
	if [ -n "$_shanty_local" ]; then
		doas cp "$src" "$dest"
	else
		scp "$src" "${_shanty_host}:${dest}"
	fi
}

_shanty_has_fn() {
	type "$1" >/dev/null 2>&1
}

_shanty_setup_remote() {
	_shanty_remotedir=$(ssh "$_shanty_host" "mktemp -d /tmp/shanty.XXXXXX")
	trap '_shanty_cleanup' EXIT

	# Upload shim
	cat <<'SHIM' | ssh "$_shanty_host" "cat > ${_shanty_remotedir}/shim.sh"
shanty_lib() { :; }
shanty_target() { :; }
shanty_vars() { :; }
shanty_stanza() { :; }
shanty_init() { :; }
SHIM

	# Upload vars
	{
		for var in $_shanty_varlist; do
			eval "val=\${${var}}"
			printf "%s='%s'\n" "$var" "$val"
		done
	} | ssh "$_shanty_host" "cat > ${_shanty_remotedir}/vars.sh"

	# Upload libs
	ssh "$_shanty_host" "mkdir -p ${_shanty_remotedir}/lib"
	for entry in $_shanty_libs; do
		name="${entry%%:*}"
		path="${entry#*:}"
		scp "$path" "${_shanty_host}:${_shanty_remotedir}/lib/${name}.subr"
	done

	# Upload shanty file
	scp "$_shanty_file" \
	    "${_shanty_host}:${_shanty_remotedir}/$(basename "$_shanty_file")"
}

_shanty_cleanup() {
	if [ -n "$_shanty_remotedir" ] && [ -z "$_shanty_local" ]; then
		ssh "$_shanty_host" "rm -rf ${_shanty_remotedir}"
	fi
}

_shanty_there() {
	fn="$1"
	if [ -n "$_shanty_local" ]; then
		"$fn"
	else
		d="$_shanty_remotedir"
		sources=". ${d}/shim.sh; . ${d}/vars.sh"
		for name in $_shanty_lib_names; do
			sources="${sources}; . ${d}/lib/${name}.subr"
		done
		sources="${sources}; . ${d}/$(basename "$_shanty_file")"
		ssh "$_shanty_host" "doas sh -c '${sources}; ${fn}'"
	fi
}

_shanty_run() {
	. "$_shanty_file"
	shanty_init

	if [ -z "$_shanty_local" ]; then
		_shanty_setup_remote
	fi

	for stanza in $_shanty_stanzas; do
		if _shanty_has_fn "${stanza}__check" \
		    && _shanty_there "${stanza}__check"; then
			echo "skip: ${stanza}"
			continue
		fi

		if _shanty_has_fn "${stanza}__here"; then
			"${stanza}__here"
		fi

		if _shanty_has_fn "${stanza}__stream"; then
			"${stanza}__stream" | _shanty_there "${stanza}__there"
		elif _shanty_has_fn "${stanza}__copy"; then
			"${stanza}__copy"
			_shanty_there "${stanza}__there"
		elif _shanty_has_fn "${stanza}__there"; then
			_shanty_there "${stanza}__there"
		fi

		echo "done: ${stanza}"
	done
}

_shanty_run
```

## Tradeoffs

**Pros:**
- Pure POSIX shell. No ansible, no Python, no YAML, no Go binary.
- Zero dependencies on remote (just base FreeBSD + SSH).
- The shanty reads as a clear, ordered sequence of stanzas.
- Each stanza's phases make the here/there boundary explicit.
- Convention over configuration: function suffixes declare the wiring.
- Check phase provides idempotency per stanza.
- No heredocs, no sed extraction. Ship the whole file, call the function.
- Reusable libraries (`.subr` files) shared across shanties.
- `.shanty` file is just functions and config. The `shanty` command drives it.

**Cons:**
- Variable serialization via shanty_vars needs careful quoting for values
  with special characters.
- Multiple SSH round-trips (upload + one per `_there` call). Could add
  ControlMaster for connection reuse.
- No dry-run mode built in (could add `shanty --dry-run`).

## Things to think about

**Config file generation.** The dist/ files are static now. If they need
templating (host-specific values), redo scripts could produce dist/ files
before the shanty runs. Keep generation separate from deployment.

**Running individual stanzas.** `shanty beastie.shanty --stanza extract_config`
runs just that stanza. Since files are uploaded once at startup, this is
trivial - just call the function. Could also support `--start-at` like
ansible's `--start-at-task`.

**ControlMaster for SSH reuse.** If SSH latency becomes noticeable, add
to `shanty_target`:
```sh
if [ -z "$_shanty_local" ]; then
    ssh -o ControlMaster=yes -o ControlPersist=60 \
        -o ControlPath=/tmp/shanty-%h -fN "$_shanty_host"
fi
```

**rset.** Worth investigating separately for its `rinstall` tool. The
"did anything change?" exit code is a useful primitive for config updates
on running systems - a different concern from BE provisioning.

**Relation to new-be and ansible.** shanty replaces both. new-be's
functions become stanzas. ansible's playbook becomes a `.shanty` file.
The `shanty` command replaces both libnewbe-remote.sh's heredocs and
ansible's remote execution.

## Alternatives considered

**drist:** Closest existing tool. POSIX sh, tar pipes, BSD origins. But
fixed execution model (files then scripts) can't handle interleaved
operations or stdin streaming. Good for simple "copy files, run script"
but not for the full BE provisioning workflow.

**cdist:** Real config management. Clean type system, explorer concept.
But Python dependency and heavyweight for 4 personal machines. Ideas
worth stealing (explorers, filesystem-as-database) but not the tool itself.

**Ansible:** Already in use. Works but heavy. Python + YAML for what are
shell commands. The deploy.yml is 200 lines of YAML doing what 50 lines
of shell can do.

**sake:** Go task runner. Clean `local: true` concept. But YAML config
and no file transfer built in.

**remotely:** Good argument escaping, persistent SSH socket. But requires
bash and rsync. The escaping idea is worth remembering if commands get complex.

**Primitives approach (previous draft):** on_host/copy_to_host/stream_to_host
functions with commands passed as strings. Worked but had quoting problems
and no structure for idempotency or step ordering. shanty adds the structure
that was missing.
