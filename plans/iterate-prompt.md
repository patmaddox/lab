---
status: draft
---

# Create an iterate prompt that combines plan, implement, refactor

A higher-level prompt that drives the full cycle: develop a plan
until it's ready, implement it, then refactor. The interesting
question is how the steps interact -- implementation may reveal
that the plan was wrong, requiring a return to planning. Refactoring
may surface new work that needs planning.

Need to figure out whether each step gates the next (plan must be
ready before executing) or whether the prompt should allow fluid
movement between modes. Multiple rounds of planning mid-implementation
seem likely -- the question is how to structure that without losing
coherence.
