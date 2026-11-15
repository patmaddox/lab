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

The skill runs unattended, so it never stops to ask the user. The
clone, its worktrees, and its forks are ours, so finish every job in
them yourself, including the ones that touch a checked-out branch or
uncommitted changes. Hand back only a change that must be made from
outside, where you cannot reach, such as one to upstream's repos, and
list it under "Your action".

## The clone

Upstream is the remote that the default branch comes from, usually
`origin`. Every other remote is a fork of ours, usually `agent`. Work
out which is which from the clone's remotes and config, and from any
CLAUDE.md that says where upstream repos live. If you cannot
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
  - Before you move a branch that a worktree has checked out, or
    switch that worktree, commit the worktree's uncommitted changes,
    untracked files included, to a new branch `wip/<branch>`, and
    push it to the branch's fork. Later runs sync it like any other
    branch.
- Leave the clone as you found it, apart from its branches. A
  worktree follows its branch: when you rebase the branch, reset the
  worktree to the new tip, and when you delete the branch, switch the
  worktree to trunk. Do the rest of your work in temporary worktrees,
  and remove them and their directories whatever the outcome.

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
   trunk if it exists. If it cannot fast-forward, move its own
   commits to a new branch, named for what they do, and point the
   local trunk at upstream's.
2. For each branch of ours, take its newest copy, local or on a fork,
   and find which of its commits since trunk have landed. If the
   copies have diverged, reconcile them first: take the copy with the
   newer tip as the base, drop the other copy's commits that have
   landed on it, rebase the rest onto it, and push the result to
   each fork that has the branch.
3. If all of them have, delete the branch locally and from each fork.
4. If some have, or the branch no longer merges cleanly with trunk,
   rebase it onto trunk, dropping the landed commits. Resolve each
   conflict so that the commit keeps its intent on top of what trunk
   now does. If a resolution changes what a commit does, check that
   its message still describes its diff, following the repo's own
   commit message rules, if it has any. Run the repo's tests or build
   if the rebase touched them. Then push the branch to the fork it is
   on, if any, and move the local branch to match. If you cannot
   resolve a conflict with confidence, or `next` has the branch's
   commits, leave the branch as it was. The maintainer resolves its
   conflicts when merging it, or asks for a reroll.
5. Otherwise, leave the branch alone.

Judging and rebasing take time. When several branches need them, do
the fetch yourself, then give each branch to a subagent of its own,
all at once so they run in parallel. Tell each to follow this skill
for that branch alone, without fetching, and to report what it did.

## Report

Keep the report short. Write one block per clone, headed by its path,
in three sections, and leave out a section that has nothing in it:

- **Actions.** Each change the run made: trunk fast-forwarded,
  branches deleted, with the trunk commits that carry their work,
  branches rebased or reconciled, with old and new tips and the
  commits dropped, uncommitted changes saved, and worktrees reset or
  switched. Write "No changes." if there were none.
- **Branches.** Each branch left in place, with its tip and whether
  it merges cleanly. For one that conflicts, name the files and why
  it was not rebased.
- **Your action.** Each change that must be made from outside, with
  the reason in a few words.
