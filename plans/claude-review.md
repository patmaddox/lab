---
status: draft
depends: [claude-submit]
---

# claude-review - incorporate patch feedback into commits

Read patches from `$(jj root)/tmp/reviews/`, parse inline review
responses (mailing-list style), and apply the feedback to the
corresponding jj commits.

The workflow mirrors a mailing-list patch review cycle:
`claude-submit` exports commits as patches (sending to the list), the
user annotates the patches with inline replies, and `claude-review`
incorporates the feedback (applying reviewer comments to the patch
set).

## Context

Two components: a deterministic shell script
(`libexec/just/claude-review.sh`) iterates through
`tmp/reviews/CLAUDE-*.patch` files in order, and for each patch
invokes a prompt (`prompts/review.md`) with the patch content and jj
change ID (extracted from the filename). The script handles the loop;
the prompt handles interpreting feedback and editing the commit.

Patches in `tmp/reviews/` are `git format-patch` output. The filename
format is `CLAUDE-NNNN-<subject>-<change_id>.patch` - the jj change ID
is the stable identifier (git commit IDs change on rewrite, change IDs
don't). The shell script extracts the change ID from the filename and
passes it to the prompt. Since commit subjects already contain "CLAUDE",
the script must replace the `git format-patch` numeric prefix
(`NNNN-CLAUDE-`) with `CLAUDE-NNNN-` to avoid doubling the prefix.
Patches must be numbered in git order (earliest commit is 0001), which
may require `--reversed` on the revset.

The user edits these files directly, adding inline responses below
diff hunks or commit message lines using `>` quoted original followed
by unquoted response - standard mailing-list reply convention.

The user may:
- Request changes to specific lines or hunks
- Ask for a commit to be abandoned entirely
- Provide general feedback on the commit message or approach

To apply changes, `jj edit <id>` checks out the target commit, the
prompt makes changes in the working copy, then moves on. Because earlier
commits in the series may change, later commits can become conflicted.
The prompt must resolve conflicts as part of integrating feedback. If a
conflict cannot be resolved, the process stops immediately with a
failure exit - do not continue to later commits that will just stay
conflicted.

Before editing, the script records the most recent non-empty change ID
(the current `@` is an empty working-copy commit that will disappear
when `jj edit` switches away). After each patch is processed, the script
runs `jj new <tip>` to restore the working copy to the tip of the
branch. The tree always starts and ends at an empty commit on top of the
series.

### Decided

- Two-part architecture: deterministic shell script loops over patches,
  prompt handles each patch
- Shell script: `libexec/just/claude-review.sh`
- Prompt: `prompts/review.md`
- Invocation: `just claude-review`
- Use `jj edit` to check out each commit, apply changes in working copy
- Stop with failure on unresolvable conflicts - do not proceed to later patches
- Filename format: `CLAUDE-NNNN-<subject>-<change_id>.patch`, script replaces
  `git format-patch` prefix to avoid doubling CLAUDE
- Working copy preservation: record tip change ID before editing, `jj new` back
  to tip after each patch

## Goal

A prompt that reads annotated patches from `tmp/reviews/` in
sequence, interprets inline review feedback, and updates each
corresponding jj commit to reflect the requested changes.

## Tasks

## Done-when

- `just claude-review` processes patches in `CLAUDE-NNNN` order
- Inline change requests are applied to the corresponding commit
- "Abandon" instructions cause `jj abandon` of the commit
- Patches with no annotations are skipped
- Each commit is updated individually (not squashed together)
