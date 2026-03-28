---
status: draft
---

# Split plan prompt into analyze and plan tasks

The plan prompt (`prompts/plan.md`) does too much in a single pass.
It tries to assess the plan, read the codebase, and fill in gaps
all at once, which makes it too aggressive about reaching a result.
The planner ends up working from an unreliable starting point -
questions that should have been asked never get asked, and gaps
slip through.

Split the work into two prompts: an analyze prompt that surfaces
all the questions and uncertainties, and a plan prompt that fills
in the spec once the foundation is solid.
