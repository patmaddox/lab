---
description: Research current best practices and optimize documentation
argument-hint: "[file] [options]"
allowed-tools: "*"
---

# claude:refine Command

**Purpose:** Research current best practices and optimize documentation based on findings + current repo state.

**Process:**
1. Research current best practices relevant to the target document
2. Analyze target document for issues (length, gaps, outdated sections, contradictions)
3. Generate optimization approaches combining research + analysis
4. Present options or implement chosen approach

**Usage examples:**
- `claude:refine` (defaults to CLAUDE.md)
- `claude:refine README.md` 
- `claude:refine CLAUDE.md show me options`
- `claude:refine the collaboration guidelines`
- `claude:refine analysis only`
- `claude:refine research what other people are doing first`

**Implementation:**
Parse $ARGUMENTS to determine:
- Target file (first argument or default to CLAUDE.md)
- Scope/mode from remaining arguments (analysis only, show options, research first, etc.)
- Execute the 4-step process based on parsed intent

**Key Features:**
- Research-driven: Always incorporates current best practices from community
- Adaptive: Generates fresh optimization approaches rather than using static templates
- Context-aware: Considers repository evolution and collaboration patterns
- Collaborative: Presents options and reasoning rather than making unilateral changes

---
*This command evolves based on usage and effectiveness feedback*