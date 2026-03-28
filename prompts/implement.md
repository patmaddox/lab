# Implement a plan

You are implementing a plan file. Your job is to pick up the next
uncompleted task, implement it with the simplest possible solution,
and check it off. One task per invocation.

## Input

You receive a plan file (markdown with YAML frontmatter). The plan
should be in `ready` or `active` status with four sections: Goal,
Context, Tasks, and Done-when.

## What you do

### 1. Verify the plan is ready

Confirm the plan has Goal, Context, Tasks, and Done-when sections.
If any are missing or too vague to act on, stop and tell the human
the plan needs more development before implementation.

### 2. Check dependencies

If the plan's frontmatter has a `depends` field, read each listed
plan and verify its status is `done`. If any dependency is not
satisfied, stop and tell the human which dependencies are blocking.

### 3. Set status to active

If the plan's frontmatter status is not already `active`, set it
to `active`.

### 4. Find the next task

Scan the Tasks section for the first unchecked item. Tasks use
markdown checkbox syntax:

```markdown
- [ ] Uncompleted task
- [x] Completed task
```

If all tasks are checked, go to step 7 (completion).

### 5. Implement the task

Read the relevant parts of the codebase and implement the task
with the simplest possible solution. Do not over-engineer, add
unnecessary abstractions, or go beyond what the task specifies.

If the task cannot be completed as written -- it is wrong, unclear,
blocked, or reality has diverged from the spec -- stop immediately.
Tell the human that the plan needs revision and explain what is
wrong. Do not attempt to fix the plan or improvise a different
approach.

### 6. Check off the task

After successful implementation, mark the task as completed in the
plan file by changing `- [ ]` to `- [x]`.

### 7. Handle completion

When all tasks are checked off:

1. Set the frontmatter status to `done`
2. Add a Postmortem section at the end of the plan:

```markdown
## Postmortem

### Claude

What worked, what was unclear, what needed adjustment.

### Pat

(filled in by Pat after reviewing the work)
```

Write the Claude subsection with honest observations about the
implementation. Leave the Pat subsection as-is for the human.

## Rules

- **One task per invocation.** Find the next unchecked task,
  implement it, check it off, stop. Do not continue to the next
  task.
- **Simplest possible solution.** Do the minimum needed to
  accomplish the task correctly. No gold-plating.
- **Do not modify the plan.** If something is wrong with the plan,
  stop and tell the human. The plan prompt handles plan changes,
  not the implementation prompt.
- **Do not commit.** The human commits when ready.
- **Do not archive.** The human handles moving completed plans to
  `plans/archive/` and regenerating INDEX.md.
- **Stop on divergence.** If what you find in the codebase
  contradicts what the plan says, stop. Do not guess or improvise.
