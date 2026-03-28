---
status: ready
---

# claude-submit - export claude() commits as patches

Export all commits matching the `claude()` jj revset as a
`git format-patch` series to `$(jj root)/tmp/reviews/`.

## Context

Part of the code review tool. This is a deterministic script, not a
prompt - no LLM involved.

The `claude()` revset is already defined:
`mutable() & subject(regex:'^\[CLAUDE\]')`.

jj exposes git commit IDs via `jj log -T 'commit_id'`, and the
backing git repo is at `$(jj git root)`. `git format-patch` works
directly with these commit IDs using `--git-dir`.

### Decided

- Output directory: `$(jj root)/tmp/reviews/`
- Invocation: `just claude-submit`
- Implementation: shell script at `libexec/just/claude-submit.sh`
- On each run, remove only `CLAUDE-*.patch` files from the output directory - preserves any non-CLAUDE files (e.g. user annotations)
- Use `-1` per commit (no series numbering), but rename filenames
  to `CLAUDE-NNNN-<change_id>-<subject>.patch` so patches sort in
  commit history order and the jj change ID is embedded in the
  filename (git commit IDs change on rewrite, change IDs don't)

## Tasks

- [ ] Create `libexec/just/claude-submit.sh` that:
  1. Creates `$(jj root)/tmp/reviews/` if needed, removes any existing `CLAUDE-*.patch` files
  2. Gets git commit IDs and jj change IDs from `jj log -r 'claude()' --no-graph -T 'commit_id ++ " " ++ change_id ++ "\n"'`
  3. Iterates commits with a counter, running `git --git-dir="$(jj git root)" format-patch -1 -o "$outdir" <git-commit>` and renaming the output to `CLAUDE-NNNN-<change_id>-<subject>.patch` so patches sort in commit history order and carry the stable jj change ID
  4. Prints the number of patches exported and the output path
- [ ] Add `claude-submit` recipe to `Justfile` that calls the script

## Done-when

- `just claude-submit` produces one `.patch` file per `claude()` commit in `tmp/reviews/`
- Empty `claude()` revset produces an empty directory and a message
- No LLM prompts, no interactivity - purely deterministic
