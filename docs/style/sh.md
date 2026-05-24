# Shell Style Guide

POSIX /bin/sh. No bashisms.

## Structure

Every script starts with a `main` function. Minimize global state -
only `readonly` constants belong at file scope.

```sh
#!/bin/sh

readonly PROGNAME="${0##*/}"

main() {
    # parse flags
    # parse arguments
    # do work
}

main "${@}"
```

Define helper functions above `main`. Extract functions when a
block has a distinct purpose, not to reduce line count.

## Function order

Organize functions top-down, from most general to most specific.
The code should tell a story - get to the point quickly and
progressively add detail. Least important stuff at the bottom.

1. General utilities (`err`, `die`, `dbg`, `usage`)
2. `main`
3. Functions `main` calls directly (e.g. `cmd::` dispatchers)
4. Functions those call, grouped by layer
5. Lowest-level helpers last

For scripts with subcommands, namespace dispatch targets with
`cmd::` and use a `case` statement in `main`:

```sh
main() {
    local cmd="${1:-}"
    case "${cmd}" in
        help | ls | clean)
            cmd::${cmd}
            ;;
        *)
            cmd::build "${@}"
            ;;
    esac
}

cmd::help() { ... }
cmd::ls() { ... }
cmd::clean() { ... }
cmd::build() { ... }
```

## Strict mode

Enable at file scope, right after the shebang:

```sh
set -eu
set -o pipefail
```

`-e` exits on unexpected non-zero return. `-u` exits on undefined
variable reference. `-o pipefail` makes a pipeline return the
rightmost non-zero exit status. FreeBSD /bin/sh supports it.

Strict mode catches mistakes but is not a substitute for tests.
Use `set -x` to debug unexpected exits.

## Parameters

Name parameters immediately. Use `shift` to consume them:

```sh
build_module() {
    local srcdir="${1}"; shift
    local flavor="${1}"; shift

    ...
}
```

Keep `shift` on the same line as the assignment to discourage
reverting to numbered parameters. Combined with `set -e`, `shift`
fails loudly when too few arguments are passed.

For variable-length argument lists, use `"${@}"`. Never capture
arguments with `"${*}"`.

## Variables

Always brace-expand: `${var}`, not `$var`. This includes `${1}`,
`${@}`, `${?}`.

### Local variables

Declare all function variables `local`. Missing `local` is a bug.

Separate declaration from command substitution so that return
values are not masked:

```sh
# Wrong - local always returns 0, masking mktemp failure
local dir="$(mktemp -d)" || die "mktemp failed"

# Right
local dir
dir="$(mktemp -d)" || die "mktemp failed"
```

Declare loop variables `local` too. Shell uses dynamic scoping -
a called function can clobber the caller's iterator.

## Conditionals

Use `[`, not `[[` or `test`. `[[` is a bashism. `[` is a builtin
in all modern shells and reads clearly in `if` statements:

```sh
if [ "${count}" -eq 0 ]; then
    ...
fi
```

Quote all variable expansions inside `[` to prevent word splitting.

## Quoting

Quote every expansion unless you specifically need word splitting
or globbing. When in doubt, quote.

```sh
cp "${src}" "${dest}"
for f in "${files}"; do
```

## Functions

Place the function name on the same line as `()`. No `function`
keyword - it is a bashism:

```sh
do_thing() {
    ...
}
```

## Error handling

Print errors to stderr. Prefix with the program name:

```sh
err() {
    echo "${PROGNAME}: ${*}" >&2
}

die() {
    err "${@}"
    exit 1
}
```

Use `err` and `warn` helpers rather than ad-hoc `echo >&2`.

## Output

Follow "no news is good news" for fast operations. Print nothing
on success unless the user asked for verbose output.

For slow operations, report progress to stderr so it does not
pollute stdout.

Direct program output to stdout. Direct status, progress, and
errors to stderr.

## Style

- Lines at most 80 characters.
- Indent with tabs where possible, spaces for alignment.
- One blank line between functions. No blank line after the
  opening brace of a function.
- Use `readonly` for constants, not `declare -r` (bashism).
- Prefer `command -v` over `which` for portability.
- Spell `getopts` (builtin), not `getopt` (external, fragile
  with whitespace).

## References

- Julio Merino, [Shell readability](https://jmmv.dev/series/shell-readability/) series (2018):
  [main](https://jmmv.dev/2018/02/shell-readability-main.html),
  [parameters](https://jmmv.dev/2018/03/shell-readability-function-parameters.html),
  [strict mode](https://jmmv.dev/2018/03/shell-readability-strict-mode.html),
  [local](https://jmmv.dev/2018/03/shell-readability-local.html)
- Julio Merino, [test, \[, and \[\[](https://jmmv.dev/2020/03/test-bracket.html) (2020)
- FreeBSD style(9) - kernel/userland code style guide
- FreeBSD style.Makefile(5) - variable expansion with `${}` not `$()`
