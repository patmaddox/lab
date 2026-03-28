---
status: done
---

# Move plan conventions from CLAUDE.md into prompts

The Plans section in CLAUDE.md describes format, lifecycle,
execution, and relationships. Most of this is only needed by the
prompts that operate on plans. Rather than creating a plans/CLAUDE.md
middle layer, put the context directly in the prompts that need it
and remove the Plans section from CLAUDE.md.

## Context

The current Plans section in CLAUDE.md (lines 117-187) contains:

- What plans are and where they live
- Format (frontmatter fields, structure)
- Lifecycle (statuses, archiving)
- Executing a plan + postmortem template
- Checking dependencies
- INDEX.md generation
- Relationship to other docs

No plans/CLAUDE.md is needed -- the prompts are the interface.
Each prompt carries the context it needs to do its job. If shared
context becomes a problem later, it can be extracted then.

Top-level CLAUDE.md does not need a pointer to plans/ either. The
prompts are invoked explicitly; there is no need for passive
discovery of plan conventions.

### Decided

- Readiness structure (Goal/Context/Tasks/Done-when) stays in
  prompts/plan.md only. If it turns out to be common context, we
  can elevate it later.
- No plans/CLAUDE.md. Prompts carry their own context.
- No pointer in top-level CLAUDE.md.
- Implement prompt is tracked separately in plans/implement-plan-prompt.md.
- Refactor prompt is tracked separately in plans/refactor-prompt.md.
- Each task is an atomic move: relocate content and remove from
  CLAUDE.md in one step, not batch additions then cleanup.

### What moves where

| Current CLAUDE.md content           | Destination          |
|-------------------------------------|----------------------|
| What plans are, where they live     | removed              |
| Format (frontmatter, structure)     | prompts/plan.md      |
| Lifecycle (statuses, archiving)     | prompts/plan.md      |
| Executing a plan + postmortem       | separate plan        |
| Checking dependencies               | separate plan        |
| INDEX.md                            | prompts/plan.md      |
| Relationship to other docs          | prompts/plan.md      |
| Ready plan structure (4 sections)   | already there        |

## Tasks

1. [x] Move plan format to prompts/plan.md -- move frontmatter fields
   (status, depends, priority), one plan per file, markdown with
   YAML frontmatter from CLAUDE.md into prompts/plan.md and remove
   from CLAUDE.md
2. [x] Move lifecycle to prompts/plan.md -- move status values and
   their meanings, archiving rules for done/abandoned/rejected
   from CLAUDE.md into prompts/plan.md and remove from CLAUDE.md
3. [x] Move INDEX.md context to prompts/plan.md -- move the INDEX.md
   generation note from CLAUDE.md into prompts/plan.md and remove
   from CLAUDE.md
4. [x] Move relationship-to-other-docs to prompts/plan.md -- move how
   plans relate to README, fieldstones, CLAUDE.md from CLAUDE.md
   into prompts/plan.md and remove from CLAUDE.md
5. [x] Remove remaining Plans section scaffolding from CLAUDE.md --
   delete the section header, intro paragraph ("What plans are,
   where they live"), and any leftover text after tasks 1-4

## Done-when

- prompts/plan.md contains all the context it needs to develop
  plans without relying on CLAUDE.md
- The Plans section is gone from CLAUDE.md
- Existing plans still work -- no format or convention changes,
  just moving where the instructions live

## Postmortem

### Claude

The plan was well-structured with atomic tasks that each moved one
piece of content and removed it from CLAUDE.md in the same step.
Task 5 (scaffolding removal) was straightforward since the previous
tasks had already moved all substantive content - only the section
header, intro paragraph, "Executing a plan", and "Checking
dependencies" subsections remained, and those were marked for
removal or tracked by separate plans. No surprises or adjustments
needed.

### Pat

(filled in by Pat after reviewing the work)
