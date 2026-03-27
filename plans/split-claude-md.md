---
status: draft
---

# Extract plan conventions from top-level CLAUDE.md

The Plans section in CLAUDE.md describes how to work with plans —
format, lifecycle, execution, postmortems. This could live closer
to the plans themselves, either as plans/CLAUDE.md or as a skill.

A skill might be better since plan execution is an action (read
plan, implement tasks, write postmortem) rather than passive
context. But plans/CLAUDE.md keeps it simple and discoverable via
the existing "check for README/CLAUDE.md" convention.

Top-level CLAUDE.md should just point to plans/ and let the local
instructions take over.
