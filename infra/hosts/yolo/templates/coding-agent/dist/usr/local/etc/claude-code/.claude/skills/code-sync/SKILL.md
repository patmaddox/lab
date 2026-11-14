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
the commits the default branch does not have yet. A commit has landed
when the default branch has its change, whether by merge,
fast-forward, cherry-pick, squash, or by hand. Every landed commit is
dropped from its branch, and every branch ends in one of three
states:

- Deleted, because all of its commits landed.
- Rebased onto the default branch and pushed again, because some of
  its commits landed, or because it no longer merges cleanly.
- Left alone, because none of its commits landed and it still merges
  cleanly.

If the current directory is inside a clone, sync that clone. If not,
sync each clone directly under the current directory, one after
another. If arguments are given, sync only the branches they name.

Finding landed commits and rebasing are slow and need judgment, so
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

## 4. Find landed commits

A branch's commits are those on its tip since `$base`:

    git rev-list --reverse "$base"..<tip>

Sort each into landed or not. First make the cheap checks in the
main loop:

- If `git merge-base --is-ancestor <tip> "$base"` succeeds, the
  branch has no commits of its own.
- `git cherry "$base" <tip>` marks with `-` each commit whose patch
  `$base` already has. Those have landed.
- If `git merge-tree --write-tree "$base" <tip>` succeeds and prints
  the same tree as `git rev-parse "$base^{tree}"`, merging the branch
  would change nothing, so all of its commits have landed. This
  catches most squash merges.

A commit that `git cherry` marks with `+` may still have landed in
another form. For each branch that the cheap checks leave with any
`+` commit, launch an integration subagent, all in one message so
they run in parallel. Use the prompt in "Integration subagent" below.
Wait for every verdict before you act on any.

A branch's landed commits are then those `git cherry` marked with
`-`, and those its subagent listed as landed. The rest remain.

## 5. Delete fully landed branches

For each branch whose commits have all landed:

1. If it is checked out in any worktree, switch that worktree to
   `$main` first. If that worktree has uncommitted changes, do not
   delete the branch. Report it instead.
2. `git branch -D <name>` for the local branch.
3. `git push <fork> --delete <name>` for each fork that has it.

Use `-D`, not `-d`, because a branch whose commits landed as a squash
or a cherry-pick is not an ancestor of `$base`, and `-d` refuses it.
The verdict is what makes the delete safe.

## 6. Test the merge for branches with nothing landed

For each branch none of whose commits landed, test a merge with
`$base`. No worktree is needed:

    git merge-tree --write-tree --quiet "$base" <tip>

Exit status 0 means it merges cleanly, so leave the branch as it is.
Status 1 means a conflict. Any other status is an error. Report it
and move on.

## 7. Rebase branches

Rebase each branch that has some landed commits, dropping them, and
each branch that conflicts. Rebase the first kind even when it merges
cleanly: a merge keeps a commit that landed in another form, such as
one from a parent branch that landed reworded.

A rebase rewrites every commit on the branch since `$base`, so first
check each of these branches against `$next`, if there is one. The
branch is published if any of its commits are in `$next`, that is if
these two counts differ:

    git rev-list --count <tip> ^"$base"
    git rev-list --count <tip> ^"$base" ^"$next"

Do not rebase a published branch. Leave it as it is, and name it
under "Your action" in the report, with its landed commits or its
conflicting files.

Launch a rebase subagent for each branch to rebase, all in one
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
- A branch rebased, with old and new tips, the remote it was pushed
  to, and the landed commits it dropped.

If the run changed nothing, write "No changes." in place of the list.

**Branches.** One line for each branch left in place, with its tip
and its state: merges cleanly, rebased, or needs attention. Name
each branch once.

**Your action.** One line for each decision or command left to the
user, with the reason in a few words: a diverged branch, a rebase
given up, a published branch with landed commits or conflicts, an
error, a `$main` that cannot fast-forward, or a checked-out branch
to reset. If nothing is left, write "None."

## Integration subagent

Fill in the angle-bracketed fields:

> Decide which commits on git branch `<name>` have already landed on
> `<base>`, in the clone at `<path>`. Do not modify any ref, the
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
> A commit has landed when `<base>` has its whole effect, even if
> later commits changed the same lines again. A commit that `<base>`
> deliberately reverted, or made unnecessary, has not landed. Report
> it as such.
>
> End your reply with exactly one verdict line, listing the commits
> that landed, each with the `<base>` commits that carry it:
>
>     LANDED: <commit>=<base commits> <commit>=<base commits> ...
>     LANDED: none
>
> Then give a few lines of evidence for each commit. Leave a commit
> out when you are not sure it landed. Dropping a commit that has not
> landed loses work, and keeping one that has costs only a rebase.

## Rebase subagent

Fill in the angle-bracketed fields. Leave out the push steps for a
local-only branch, and tell the subagent to move the local branch
with `git branch -f <name> HEAD` instead, unless it is checked out.

> Rebase git branch `<name>` onto `<base>` and push it to the remote
> `<remote>`, in the clone at `<path>`. The branch tip is `<tip>`.
> These commits on it have already landed on `<base>`, so drop them:
> `<landed commits, or none>`. A trial merge with `<base>` conflicts
> in: `<files, or none>`.
>
> 1. Make a worktree of your own, so the main checkout stays as it
>    is:
>
>        wt="$(mktemp -d)/<name>"
>        git worktree add --detach "$wt" <tip>
>
> 2. In `$wt`, rebase onto `<base>`. Drop the landed commits in the
>    same rebase, by marking each `drop` in the todo list with a
>    script as the sequence editor, so that no editor opens:
>
>        GIT_SEQUENCE_EDITOR='sed -i.bak -E "s/^pick (<sha>|<sha>) /drop \\1 /"' \
>            git rebase -i <base>
>
>    Give each sha as its first seven characters, which every todo
>    line's abbreviation starts with. With no landed commits, run
>    `git rebase <base>`.
> 3. When a commit conflicts, read it with `git show`, read the
>    `<base>` commits that touch the same files, and resolve the
>    conflict so the commit keeps its intent on top of what `<base>`
>    now does. If `<base>` already made a commit's change, let the
>    rebase drop it.
> 4. If a resolution changes what a commit does, and not just where
>    its lines sit, check that its message still describes its diff.
>    Follow the repo's own commit message rules, from its CLAUDE.md
>    or a skill, if it has any.
> 5. Check that the landed commits are gone and every other commit
>    remains, by comparing `git log --oneline <base>..HEAD` with the
>    branch's commits.
> 6. If the repo has tests or a build that the rebase touched, run
>    them in `$wt`.
> 7. Push only when the rebase finished and you are confident in
>    every resolution. Pin the push to the old tip, so it fails if
>    anyone moved the branch in the meantime:
>
>        git push --force-with-lease=<name>:<tip> <remote> HEAD:refs/heads/<name>
>
>    Push to no other remote.
> 8. If you cannot resolve a conflict with confidence, run
>    `git rebase --abort` and push nothing.
> 9. Remove the worktree with `git worktree remove --force "$wt"`
>    whatever the outcome.
>
> End your reply with exactly one result line:
>
>     RESULT: pushed <old tip> -> <new tip>
>     RESULT: gave-up <reason>
>
> Then list each landed commit dropped, each conflict and how you
> resolved it, any other commit that dropped out, and any message
> you changed.
