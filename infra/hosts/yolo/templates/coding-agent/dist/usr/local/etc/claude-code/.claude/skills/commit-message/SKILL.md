---
name: commit-message
description: >
  Write and maintain commit messages in the house style, which
  combines FreeBSD and git.git conventions, and keep each message
  true to its diff. Use whenever you write a commit message, and
  whenever you change a commit's diff or message: git commit, commit
  --amend, a fixup or squash, splitting a commit, or resolving a
  conflict in a cherry-pick or rebase. Also use when asked to rewrite,
  fix, or tidy commit messages.
argument-hint: "[revision-range]"
---

# commit-message

A commit message must follow the house style and must describe the
diff it sits on, all of it and nothing else. This skill covers both.
Apply it every time a commit gains a message or its diff changes.

When invoked by hand, check each commit in the revision range
`$ARGUMENTS`, such as `origin/trunk..HEAD`. A single revision means
that commit alone. If none is given, check `HEAD`.

The house style takes its shape from FreeBSD and its body from
git.git. Be concise. Every line must tell the reader something the
diff does not. Where a repo documents conventions of its own, in its
README, CONTRIBUTING, or CLAUDE.md, follow those instead.

## When it applies

- **New commit.** `git commit`. Write the message in house style
  from the start, in a file passed with `-F`.
- **Amend.** `git commit --amend` that changes the diff. Check that
  every claim still holds and that every new hunk is explained.
- **Squash or fixup.** Folding commits together, by
  `git rebase --autosquash` or `git merge --squash`, joins or drops
  their messages. The result is almost never right. Rewrite the
  message so it describes the combined diff as one change.
- **Split.** Each half starts with the original message, or none.
  Give each half a message that covers only its own diff.
- **Resolved conflict.** A cherry-pick or rebase whose conflicts you
  resolved by hand moved the diff under the message. Check it as
  for an amend.

A rebase or cherry-pick with no conflicts leaves each diff as it was,
so its messages need no check.

## Procedure

1. List the commits, oldest first:

       git rev-list --reverse --no-merges <range>

2. Refuse any commit that is published: an ancestor of upstream's
   default branch, or of its `next` if it has one. For each commit:

       git merge-base --is-ancestor <commit> origin/HEAD
       git merge-base --is-ancestor <commit> origin/next

   If either succeeds for any commit, name those commits and stop
   without rewriting any.
3. For each commit, read its current message and diff with
   `git show <commit>`. Learn why the change was made from the
   existing message and the diff.
4. Check that the message is current and complete:
   - Keep every fact the old message states, unless the diff shows
     it is wrong. Drop claims about code the diff no longer touches.
   - Explain why for every part of the diff a reader would ask about.
     A hunk the message does not account for is a sign the message
     is stale, or that the commit should be split.
5. Write the new message to a temporary file and apply it. Skip any
   commit whose message already conforms. The working tree must be
   clean.
   - For `HEAD`:

         git commit --amend --only -F "$tmp"

   - For an older commit, make an `amend!` commit, whose message is
     `amend! ` and the old subject, a blank line, and the whole new
     message. Then fold it in:

         { printf 'amend! %s\n\n' "$(git log -1 --format=%s <commit>)"
           cat "$tmp"; } > "$tmp.amend"
         git commit --allow-empty --only -F "$tmp.amend"
         git rebase --autosquash <commit>~1

     Make the `amend!` commits for every commit first, then rebase
     once from the oldest. Use `--root` in place of `<commit>~1` for
     a root commit.
6. Report each commit with its old and new subject. Rewriting changes
   the hashes, so name each by its new hash.

## Subject

    <area>: <Imperative summary>

- `<area>` is the subdirectory the change lives in, e.g.
  `infra/hosts/rowdy` or `src/lab-process-mail`.
- Capitalize the first word after the colon.
- Use the imperative mood: "Add", "Drop", "Block", not "Added" or
  "Adds".
- Aim for about 50 characters, and never exceed 72.
- No trailing period.

## Body

Wrap at 72 columns. Leave one blank line after the subject.

Follow git.git's order:

1. **Status quo.** Describe how things work now and why that is a
   problem. Use the present tense, as a fact about the tree before
   the patch.
2. **Change.** Say what the patch does, in the imperative, as an
   order to the codebase: "Name it as the rule's destination." Keep
   this short, because the diff carries the detail.
3. **Consequences**, only when needed. Cover side effects, what is
   unaffected and why, or alternatives you rejected.

Explain why, not what. Do not narrate the diff, and do not write
"This patch" or "I changed".

## Omit the body when it adds nothing

If the subject already says everything a reader needs, write no
body. Typical cases are a typo fix, a rename, an obvious follow-up,
or a change whose reason is the subject itself.

    infra/hosts/rowdy: Permit root SSH login by key

Do not pad a body to make it exist. One sentence is fine. A body
that restates the subject is worse than none.

## Concision

- Prefer short declarative sentences to clauses joined with
  semicolons.
- Cut hedges, filler, and sentences that restate the diff.
- If the body sprawls, the commit probably does too much. Split it.

## Describe the patch, not its history

A patch stands alone, and so does its message. Describe the change
as it stands, or the before and after of applying it. A reader with
only this commit must understand it in full.

Do not describe how the patch evolved. Phrases like "rewrap the
earlier version" or "unchanged from v1" point at a version that is
lost once history is rewritten. Do not mention review rounds, later
patches in the series, or patches not yet sent. You may refer to
earlier commits already in the tree.

When you revise a patch, write the message as if this were the first
and only version. Version notes belong in the cover letter, or below
the `---` of a single patch.

## Example

    infra/hosts/rowdy: Pass WireGuard only to rowdy's WAN address

    The WireGuard rule names a port but no destination, so it passes UDP
    51820 to any address arriving on the WAN. A host on the ISP's side
    can send packets addressed to the inside networks, and rowdy forwards
    them to whatever listens on that port there.

    Only rowdy's own WAN address needs to receive WireGuard. Name it as
    the rule's destination.

The first paragraph is the status quo and its problem. The second
gives the reasoning and then the change, as a single order.

## Trailers

Add a trailer only when it carries a fact, e.g. `Fixes: <commit>` for
a commit that repairs an earlier one. Do not add Co-Authored-By.
