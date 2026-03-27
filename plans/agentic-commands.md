---
status: draft
---

# Agentic commands decoupled from Claude Code

## Problem

Skills like `/todo` and `/fieldstone` only work inside the Claude
Code TUI. They can't be invoked from `claude -p`, other LLMs, or
plain shell scripts. This couples useful workflows to a specific
tool's interactive mode.

## Goals

- Run agentic commands from any context: shell, `claude -p`,
  Claude Code TUI, other LLMs
- Keep skills as a useful layer but don't require them
- Single source of truth for what a command does — no duplicating
  logic between a skill and a script

## Open questions

- What's the right invocation surface? Plain shell scripts that
  embed a prompt and pipe to `claude -p`? Markdown specs that any
  LLM can read? Both?
- How should skills relate to the standalone commands — should a
  skill just be a thin wrapper that calls the script, or should
  the script be generated from the skill spec?
- What's the minimal interface a command needs? (args, repo root,
  access to files — anything else?)
- Should commands be composable — e.g. a higher-level "capture"
  command that decides whether something is a todo or fieldstone?
- How do we handle commands that need interactive clarification
  vs ones that should just run?
- What role does CLAUDE.md context play — should commands carry
  their own context or rely on the caller injecting it?
