# CLI Design Style Guide

## Architecture

The CLI is a presentation layer. Separate it from program logic.

Three phases:
1. **Gather input** - parse flags, arguments, stdin (frontend)
2. **Process** - business logic, computation (backend)
3. **Display results** - format output, report errors (frontend)

Backend code should never write directly to stdout or stderr.
Use callbacks or return values to communicate status.

## Interface patterns

### Single-command tools

Syntax: `tool [options] [arguments]`

Use for tools that do one thing. Flags fine-tune behavior - they
should never be required. If a value is mandatory, make it a
positional argument.

### Subcommand tools

Syntax: `tool [general-options] command [command-options] [args]`

General options apply to every command. Command-specific options
come after the subcommand. Do not place command-specific flags
before the subcommand name.

When multiple subcommands need a similar flag, duplicate it per
command rather than promoting it to a general option that some
commands ignore.

## Flags

Flags express optionality. Never require them.

Valid uses:
- Debug/verbose modes
- Output formatting
- Configuration file paths
- Optional parameters with sensible defaults

Invalid uses:
- Required data (use positional arguments)
- Action selection (use subcommands)

## Option parsing

Use the platform's standard parser. Do not write your own.

- Shell: `getopts` builtin (not external `getopt`)
- C: `getopt(3)` / `getopt_long(3)`
- Python: `argparse`

## Help

Show help only when explicitly requested, not after errors.

After a usage error, print at most two lines: the error and a
pointer to help. Do not dump the full usage text.

Send help output to stdout - it is not an error.

Keep help accurate. Couple flag definitions with their
descriptions so they stay in sync.

### Single-command tools

Use `--help` following GNU convention. Accept that this is a
pragmatic exception to the "flags are optional" rule.

### Subcommand tools

Implement `help` as a subcommand:

```
tool help
tool help <command>
```

## Error reporting

### Usage errors

User invoked the tool wrong. Keep messages short and actionable:

```
tool: unknown option --path; see 'tool help' for usage
```

### Application errors

Something external failed. Include full context:

```
tool: cannot open /etc/tool.conf: No such file or directory
```

Annotate errors as they propagate so the user sees the chain of
cause, not just the leaf error.

### General rules

- Print errors to stderr.
- Prefix with the program name.
- Never use stack traces as error messages.
- Catch unexpected errors at the top level. Print debug info
  and ask the user to report the issue.
- Exit 0 on success, 1 on failure.

## Output

### Verbosity

Fast tools: silent on success. "No news is good news."

Slow tools: report progress so the user knows it has not stalled.
Print progress to stderr.

### Message format

Prefix messages with program name, a colon, and a space. Use a
severity indicator:

```
tool: I: starting backup of /data
tool: W: skipping unreadable file foo.dat
tool: E: cannot write to /backup: permission denied
```

`I` for info, `W` for warning, `E` for error. The letter prefix
keeps severity explicit and messages greppable.

### Routing

- stdout: program output only
- stderr: errors, warnings, info, progress, debug

A `--quiet` or `--verbose` flag should affect stderr content, never
stdout.

## Screen wrapping

Wrap structured output (help text, tables) to the terminal width.

Do not wrap error and warning messages. Let the terminal handle
it. Explicit line breaks in error text break copy-paste and
confuse terminal emulators that track soft wraps.

## Interactive prompts

Avoid prompts in the middle of long operations. When prompts are
necessary:

1. Gather all input upfront before starting work.
2. If that is not possible, defer questions to the end.
3. If neither works, warn at startup that interaction will be
   needed.
4. Always provide a non-interactive alternative via flags or
   defaults.

## Usage synopsis

Follow the conventions from FreeBSD style(9):

```
usage: tool [-aDde] [-b arg] [-m arg] req1 req2 [opt1 [opt2]]
```

- Boolean options together in one bracket group, sorted.
- Options with arguments each in their own bracket group, sorted.
- Required arguments next, in order.
- Optional arguments last, in nested brackets.

## References

- Julio Merino, [CLI design](https://jmmv.dev/series/cli-design/) series (2013):
  [introduction](https://jmmv.dev/2013/08/cli-design-series-introduction.html),
  [presentation layer](https://jmmv.dev/2013/08/cli-design-cli-is-presentation-layer.html),
  [error reporting](https://jmmv.dev/2013/08/cli-design-error-reporting.html),
  [help](https://jmmv.dev/2013/08/cli-design-requesting-and-offering-help.html),
  [flags](https://jmmv.dev/2013/08/cli-design-putting-flags-to-good-use.html),
  [option parsing](https://jmmv.dev/2013/08/cli-design-do-not-reinvent-option.html),
  [subcommands](https://jmmv.dev/2013/09/cli-design-subcommand-based-interfaces.html),
  [single-command](https://jmmv.dev/2013/09/cli-design-single-command-interfaces.html),
  [output](https://jmmv.dev/2013/09/cli-design-handling-output-messages.html),
  [screen wrapping](https://jmmv.dev/2013/09/cli-design-screen-wrapping.html),
  [prompts](https://jmmv.dev/2013/09/cli-design-consider-interactive-prompts.html)
- FreeBSD style(9) - usage synopsis conventions, getopt(3) patterns
