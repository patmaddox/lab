---
name: code-sync
description: >
  Bring git clones up to date with upstream and tidy their branches.
  Fetch every remote, delete each branch whose work has landed on the
  default branch, and rebase each live branch that no longer merges
  cleanly with it, then push it again. Use on /code-sync, or when
  asked to sync, refresh, or clean up branches.
argument-hint: "[branch...]"
---

# code-sync

Sync a git clone with its upstream. Every branch ends in one of three
states: deleted because the default branch has its work, left alone
because it still merges cleanly, or rebased onto the default branch
and pushed again.

If the current directory is inside a clone, sync that clone. If not,
sync each clone directly under the current directory, one after
another. If arguments are given, sync only the branches they name.

Checking integration and rebasing are slow and need judgment, so
each runs in a subagent of its own. The main loop reads the clone's
layout, fetches, gathers branches, makes the cheap checks, acts on
the verdicts, and reports.

## 1. Read the clone's layout

Nothing about a clone is known in advance. Derive the upstream
remote, the default branch, and where each branch is pushed from the
clone's own config. Do not assume any remote or branch name.

**Upstream remote.** This is where the default branch comes from.
Find it with the first rule that gives exactly one remote:

1. `git remote` lists only one remote.
2. Exactly one remote `<r>` has a local branch `<b>` that tracks the
   remote's default branch. That is, `branch.<b>.remote` is `<r>`,
   and `branch.<b>.merge` names the branch that
   `refs/remotes/<r>/HEAD` points at.
3. Exactly one remote is not `remote.pushDefault`.

If no rule settles it, list the remotes with their URLs and ask the
user which is upstream. Call the answer `$up`.

**Default branch.** Read it from upstream after the fetch in step 2,
because upstream may have changed it:

    git ls-remote --symref "$up" HEAD

The first line names `refs/heads/<name>`. Call `$up/<name>` `$base`,
and call `<name>` `$main`, the local branch of the same name. If
`refs/remotes/$up/HEAD` points elsewhere, run
`git remote set-head "$up" --auto`.

**Next branch.** If `$up` has a branch `next`, call `$up/next`
`$next`. It is published, like `$base`: never rewrite a commit that
is an ancestor of either, unless the user tells you to.

**Fork remotes.** Every remote other than `$up` is a fork. Branches
on a fork are ours to delete and rewrite.

**Push remote of a branch.** For branch `<b>`, take the first that
applies:

1. The fork that already has `<b>`. If more than one does, ask.
2. The remote of `git rev-parse --abbrev-ref <b>@{push}`, if that
   resolves. It often does not, for a branch that tracks the default
   branch under another name.
3. The only fork, if there is just one.

If none applies, the branch is local only.

**Upstream is not ours.** Never push to `$up`, and never delete its
branches, without asking the user first. A branch whose push remote
is `$up` still gets its local checks, but ask before deleting or
force-pushing its copy on `$up`. Ask once for the whole run, listing
every branch the answer covers.

## 2. Fetch

    git fetch --prune --all

If the local `$main` exists, fast-forward it to `$base`, with
`git merge --ff-only "$base"` when it is checked out, or
`git fetch . "$base:$main"` when it is not. If it cannot
fast-forward, report it and leave it alone.

## 3. Gather branches

The candidates are local branches and branches on fork remotes,
joined by name. Branches on `$up` that no local branch tracks belong
to others, so leave them out.

    git for-each-ref --format='%(refname:short)' refs/heads
    git for-each-ref --format='%(refname:lstrip=3)' refs/remotes/<fork>

Skip `$main`, and `HEAD` on each remote.

For each name, note its local tip and its tip on each fork. When two
tips differ, find which contains the other with
`git merge-base --is-ancestor`, and work on the one that is ahead. If
they have diverged, do not touch the branch. Report it as diverged
with each tip, and move on.

## 4. Check integration

A branch is integrated when `$base` already has all of its changes,
whether they landed by merge, fast-forward, cherry-pick, squash, or
by hand.

First make the cheap checks in the main loop. The branch is
integrated if any holds:

- `git merge-base --is-ancestor <tip> "$base"` succeeds.
- `git cherry "$base" <tip>` prints no line that starts with `+`.
- `git merge-tree --write-tree "$base" <tip>` succeeds and prints
  the same tree as `git rev-parse "$base^{tree}"`. Merging the branch
  would change nothing, which catches most squash merges.

Every other branch needs a closer look. Launch an integration
subagent for each, all in one message so they run in parallel. Use
the prompt in "Integration subagent" below. Wait for every verdict
before you act on any.

## 5. Delete integrated branches

For each integrated branch:

1. If it is checked out in any worktree, switch that worktree to
   `$main` first. If that worktree has uncommitted changes, do not
   delete the branch. Report it instead.
2. `git branch -D <name>` for the local branch.
3. `git push <fork> --delete <name>` for each fork that has it.

Use `-D`, not `-d`, because a branch that landed as a squash or a
cherry-pick is not an ancestor of `$base`, and `-d` refuses it. The
verdict is what makes the delete safe.

## 6. Test the merge for live branches

For each branch that is not integrated, test a merge with `$base`.
No worktree is needed:

    git merge-tree --write-tree --quiet "$base" <tip>

Exit status 0 means it merges cleanly, so leave the branch as it is.
Status 1 means a conflict. Any other status is an error. Report it
and move on.

## 7. Rebase conflicting branches

A rebase rewrites every commit on the branch since `$base`, so first
check each conflicting branch against `$next`, if there is one. The
branch is published if any of its commits are in `$next`, that is if
these two counts differ:

    git rev-list --count <tip> ^"$base"
    git rev-list --count <tip> ^"$base" ^"$next"

Do not rebase a published branch. Leave it as it is, and name it
under "Your action" in the report, with the conflicting files.

Launch a rebase subagent for each conflicting branch, all in one
message so they run in parallel. Use the prompt in "Rebase subagent"
below. Each works in a worktree of its own, so they do not touch the
main checkout or each other. A local-only branch has no push remote,
so its subagent updates the local branch instead of pushing.

When a subagent reports that it pushed, update the local branch to
match, if one exists and is not checked out:

    git fetch <remote> +<name>:<name>

The `+` is needed because a rebased branch does not fast-forward.
If the local branch is checked out, report that it needs a
`git reset --hard <remote>/<name>` and leave that to the user, so
that nothing in the working tree is lost.

## 8. Report

Keep the report short. Give the reader what changed, where each
branch stands, and what they must do. Leave out the clone's layout,
the steps taken, and the reasoning behind a verdict, unless a section
below needs them.

Write one block per clone, headed by its path, in three sections.
Leave out a section that has nothing to report.

**Actions.** One line for each change the run made:

- `$main` fast-forwarded, with old and new tips.
- A branch deleted, with the `$base` commits that carry its work, and
  the forks it was deleted from.
- A branch rebased, with old and new tips, and the remote it was
  pushed to.

If the run changed nothing, write "No changes." in place of the list.

**Branches.** One line for each branch left in place, with its tip
and its state: merges cleanly, rebased, or needs attention. Name
each branch once.

**Your action.** One line for each decision or command left to the
user, with the reason in a few words: a diverged branch, a rebase
given up, a published branch that conflicts, a partial
integration, an error, a `$main` that cannot
fast-forward, or a checked-out branch to reset. If nothing is left,
write "None."

## Integration subagent

Fill in the angle-bracketed fields:

> Decide whether the work on git branch `<name>` has already landed
> on `<base>`, in the clone at `<path>`. Do not modify any ref, the
> index, or the working tree. Read-only git commands only.
>
> The branch tip is `<tip>`, and it forks from `<base>` at
> `<merge-base>`. `git cherry` matched no patch for these commits:
> `<list of + commits>`.
>
> For each such commit, look on `<base>` since the merge base for the
> same change landing another way: reworded, squashed with others,
> split, or with conflicts resolved. Search the log by subject, by
> the paths the commit touches
> (`git log <merge-base>..<base> -- <paths>`), and by its content
> (`git log -S` or `-G`). Then compare the diffs.
>
> Also try `git merge-tree --write-tree <base> <tip>`. If the merge
> succeeds and its tree equals `git rev-parse <base>^{tree}`, the
> branch adds nothing.
>
> A commit counts as landed when `<base>` has its whole effect, even
> if later commits changed the same lines again. A commit that
> `<base>` deliberately reverted, or made unnecessary, is not landed.
> Report it as such.
>
> End your reply with exactly one verdict line:
>
>     VERDICT: integrated <base commits carrying the work>
>     VERDICT: live
>     VERDICT: partial <commits not landed>
>
> Then give a few lines of evidence for each commit. Say `live`
> when you are not sure. A wrong `integrated` loses work, and a wrong
> `live` costs only a rebase.

Act on `integrated` by deleting the branch. Treat `live` and
`partial` as live. Name a partial branch under "Your action" in
the report, since a rebase would drop its landed commits.

## Rebase subagent

Fill in the angle-bracketed fields. Leave out the push steps for a
local-only branch, and tell the subagent to move the local branch
with `git branch -f <name> HEAD` instead, unless it is checked out.

> Rebase git branch `<name>` onto `<base>` and push it to the remote
> `<remote>`, in the clone at `<path>`. The branch tip is `<tip>`. A
> trial merge with `<base>` conflicts in: `<files>`.
>
> 1. Make a worktree of your own, so the main checkout stays as it
>    is:
>
>        wt="$(mktemp -d)/<name>"
>        git worktree add --detach "$wt" <tip>
>
> 2. In `$wt`, run `git rebase <base>`. When a commit conflicts, read
>    it with `git show`, read the `<base>` commits that touch the same
>    files, and resolve the conflict so the commit keeps its intent
>    on top of what `<base>` now does. If `<base>` already made a
>    commit's change, let the rebase drop it.
> 3. If a resolution changes what a commit does, and not just where
>    its lines sit, check that its message still describes its diff.
>    Follow the repo's own commit message rules, from its CLAUDE.md
>    or a skill, if it has any.
> 4. If the repo has tests or a build that the conflicting files
>    touch, run them in `$wt`.
> 5. Push only when the rebase finished and you are confident in
>    every resolution. Pin the push to the old tip, so it fails if
>    anyone moved the branch in the meantime:
>
>        git push --force-with-lease=<name>:<tip> <remote> HEAD:refs/heads/<name>
>
>    Push to no other remote.
> 6. If you cannot resolve a conflict with confidence, run
>    `git rebase --abort` and push nothing.
> 7. Remove the worktree with `git worktree remove --force "$wt"`
>    whatever the outcome.
>
> End your reply with exactly one result line:
>
>     RESULT: pushed <old tip> -> <new tip>
>     RESULT: gave-up <reason>
>
> Then list each conflict and how you resolved it, any commit that
> dropped out, and any message you changed.
