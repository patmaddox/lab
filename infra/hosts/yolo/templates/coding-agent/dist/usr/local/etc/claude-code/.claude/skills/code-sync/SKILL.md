---
name: code-sync
description: >
  Bring git clones up to date with upstream and tidy their branches.
  Fetch every remote, find each branch's commits that have already
  landed on the default branch, and drop them: delete a branch whose
  commits have all landed, and rebase a branch that carries some, or
  that no longer merges cleanly, then push it again. Use on
  /code-sync, or when asked to sync, refresh, or clean up branches.
argument-hint: "[branch...]"
---

# code-sync

Sync a git clone with its upstream, so that each branch carries only
the commits that upstream's default branch does not have yet.

If the current directory is inside a clone, sync that clone. If not,
sync each clone directly under the current directory, one after
another. If arguments are given, sync only the branches they name.

The skill runs unattended, so it never stops to ask the user. What it
cannot decide, or must not touch, it leaves alone and reports under
"Your action".

## The clone

Upstream is the remote that the default branch comes from, usually
`origin`. Every other remote is a fork of ours, usually `agent`. Work
out which is which from the clone's remotes and config. If you cannot
tell which remote is upstream, sync nothing in the clone, and report
its remotes with their URLs.

Call upstream's default branch trunk, and read its name from upstream
after fetching, because upstream may have changed it. Upstream may
also have a `next` branch.

A branch is ours if it is a local branch or is on a fork. Branches on
upstream that no local branch tracks belong to others. Leave them
out, and leave out trunk itself.

## Rules

- Never push to upstream, and never delete a branch there.
- Never rewrite a commit that trunk or `next` contains.
- Never lose work:
  - Drop a commit only when you are sure it landed. Dropping one
    that has not loses work, and keeping one that has costs only a
    rebase.
  - Force-push only with a lease on the tip you saw on that remote.
  - Leave alone a branch whose local and fork copies have diverged.
  - Do not move or delete a branch that is checked out in a
    worktree. Report the command that would finish the job.
- Leave the clone as you found it, apart from its branches. Do your
  work in temporary worktrees, and remove them and their directories
  whatever the outcome.

Report each branch that a rule stops you from finishing.

## Landed commits

A commit has landed when trunk has its whole effect, even if later
commits changed the same lines again. It may have landed by merge,
fast-forward, or cherry-pick, but also squashed with others, split,
reworded, with conflicts resolved, or by hand. An earlier version of
a change has landed too, once a later version of it has, such as a
reroll of the same topic, even if its code differs: when v3 of a
topic lands, its v1 and v2 are obsolete. A commit that trunk reverted
on purpose, or made unnecessary by unrelated work, has not landed.

Deciding takes judgment, because the match is rarely exact.
`git cherry` finds commits whose patch trunk has, and a merge with
trunk that changes nothing means the whole branch landed. For the
rest, look in trunk's log since the branch forked, by subject, by the
paths the commit touches, and by content with `git log -S` or `-G`,
and compare the changes.

## Each branch

1. Fetch every remote with `--prune`, and fast-forward the local
   trunk if it exists.
2. For each branch of ours, take its newest copy, local or on a fork,
   and find which of its commits since trunk have landed.
3. If all of them have, delete the branch locally and from each fork.
4. If some have, or the branch no longer merges cleanly with trunk,
   rebase it onto trunk, dropping the landed commits. Resolve each
   conflict so that the commit keeps its intent on top of what trunk
   now does. If a resolution changes what a commit does, check that
   its message still describes its diff, following the repo's own
   commit message rules, if it has any. Run the repo's tests or build
   if the rebase touched them. Then push the branch to the fork it is
   on, if any, and move the local branch to match. If you cannot
   resolve a conflict with confidence, give up on the branch and
   report it.
5. Otherwise, leave the branch alone.

Judging and rebasing take time. When several branches need them, do
the fetch yourself, then give each branch to a subagent of its own,
all at once so they run in parallel. Tell each to follow this skill
for that branch alone, without fetching, and to report what it did.

## Report

Keep the report short. Write one block per clone, headed by its path,
in three sections, and leave out a section that has nothing in it:

- **Actions.** Each change the run made: trunk fast-forwarded,
  branches deleted, with the trunk commits that carry their work, and
  branches rebased, with old and new tips and the commits dropped.
  Write "No changes." if there were none.
- **Branches.** Each branch left in place, with its tip and whether
  it merges cleanly.
- **Your action.** Each decision or command left to the user, with
  the reason in a few words.
