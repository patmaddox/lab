> Why do you set both procname and command? And why is one using the beam_path and the other the bin_path?

`command` is what gets invoked - the release shell script (`bin/myapp start`). `procname` is what rc.subr looks for in the process table when checking status or stopping the service. From `rc.subr(8)`: "`check_pidfile` ensures the process with that PID is running and its first argument matches `procname`."

The release script `exec`s into `beam.smp` (the BEAM VM), so the actual running process is `beam.smp`, not the shell script. If `procname` pointed at the shell script, `service myapp status` would never find it.

`command` = what you run. `procname` = what ends up in the process table.

> Why do you use /usr/local as the base path for your binary?

`/usr/local` is the standard prefix for all third-party software on FreeBSD (`hier(7)`). The app goes under `libexec/` because `hier(7)` defines it as "utilities executed by other programs" - a BEAM release is a self-contained runtime, not a user-facing CLI tool.

> What does the `:` in front of this line do?

`: ${VAR:=default}` is a POSIX shell idiom. `:` is the null command; the `${VAR:=default}` expansion sets `VAR` if unset/empty. Net effect: provide a default that users can override in `/etc/rc.conf`. See `sh(1)`, "Parameter Expansion."

> Are RELEASE_TMP and ERL_CRASH_DUMP useful for all BEAM applications, or is it Elixir-specific?

Both are BEAM-level. `ERL_CRASH_DUMP` is an Erlang/OTP feature - the VM writes a diagnostic dump on abnormal termination to this path (`erl(1)`). `RELEASE_TMP` is used by OTP release scripts for runtime temp files (log output, pipes for console attachment). Any BEAM language (Erlang, Elixir, Gleam) benefits, though Gleam's `entrypoint.sh` may handle tmp differently - worth checking.

> What is RELEASE_TMP being used for in the prestart?

It ensures the directory exists before the VM starts. The BEAM expects it to be there for writing log files and named pipes. Placing it under `/var/run/${name}` follows FreeBSD convention for ephemeral runtime state - it gets cleaned on reboot (`hier(7)`).

> Is exporting these all that's required for them to be used by the BEAM?

Yes. The VM reads `ERL_CRASH_DUMP` and `RELEASE_TMP` as standard environment variables. `export` before the `daemon` call is all that's needed.

> What are your typical daemon flags here?

The configurable `daemon_flags` is typically just `-u <user>` when running as a non-root user. The rest are hardcoded in the start function: `-t` (title), `-p` (pidfile), `-f` (close fds), `-H` (reopen log on SIGHUP), `-o` (log file). See `daemon(8)`.

> What is ROOT_DIR necessary? I mean, in this context, why would it be used?

The release boot script uses it to locate `lib/`, `releases/`, and `erts-*/` within the install directory. Elixir's release script derives it automatically from the script's own path. For Gleam, check whether `entrypoint.sh` does the same or needs it set explicitly.

> What is /var/run/ used for in FreeBSD? Is there a place where these things are defined?

`/var/run/` holds ephemeral runtime state: PID files, sockets, etc. Cleared on reboot. The canonical reference for FreeBSD directory layout is `hier(7)` - covers `/var/run/`, `/var/log/`, `/var/db/`, `/usr/local/etc/`, and everything else.
