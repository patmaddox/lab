---
status: draft
---

# Split freebsd-src PLAN.md into design doc and plans

Split the monolithic oss/freebsd-src/PLAN.md into a durable DESIGN.md
(architecture, branch model, build system) and individual plan files
per implementation phase.

## Goal

oss/freebsd-src/ has a DESIGN.md with the two-loop architecture,
branch model, and build system design. Each implementation phase is
a separate plan file in plans/ with its own status and lifecycle.
PLAN.md is removed.

## Context

Current PLAN.md mixes durable design (the two-loop model, branch
model) with ephemeral phase checklists. The design content is
reference material that stays useful after implementation. The phases
are work plans that should be tracked independently.
