---
description: >
  Enforce shell and CLI style guides when writing or reviewing
  shell scripts and command-line tools. TRIGGER when creating or
  modifying .sh files, shell scripts, CLI tools, or code that
  parses arguments, handles flags, or produces terminal output.
user-invocable: false
allowed-tools: Read, Grep, Glob
---

# style

Before writing or modifying shell scripts or CLI tools, read the
project style guides:

1. **Shell style**: Read `docs/style/sh.md` at the repo root.
   Covers script structure (main function pattern), strict mode,
   parameter handling, local variables, quoting, conditionals,
   error handling, and output conventions.

2. **CLI design**: Read `docs/style/cli.md` at the repo root.
   Covers architecture (presentation/logic separation), interface
   patterns (single-command vs subcommand), flag design, option
   parsing, help systems, error reporting, output formatting,
   and interactive prompt guidelines.

Apply these guides to all new code and modifications. When
reviewing existing code, note style violations but do not fix
them unless the surrounding code is already being changed.

## Quick reference

- POSIX /bin/sh only, no bashisms
- Every script has a `main` function
- `set -eu` at the top
- Name parameters with local + shift
- `${var}` not `$var`
- `[` not `[[` or `test`
- Quote all expansions
- Errors to stderr, prefixed with program name
- Flags are optional - never require them
- Silent on success for fast tools
- stdout for output, stderr for everything else
