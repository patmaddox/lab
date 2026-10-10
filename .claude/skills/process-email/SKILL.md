---
name: process-email
description: >-
  Process the oldest message in your lab-devel inbox and act on it.
  Gather the message's thread and related list context with subagents,
  do the work it asks for, post any patches as their own series, and
  reply on the list, pushing to the submissions remote. Never use
  Gmail or any external mail tool. The operator does not read your
  stdout, so the result must land on the list.
disable-model-invocation: true
---

# process-email

One pass takes the single oldest message in your inbox, does whatever
it asks, and answers it on the list. The answer is always a reply; any
patches go out first as their own series, which the reply cites. Loop
the skill to drain the inbox.

The list is a maildir carried by jj on the `mail` bookmark.
zib/patch-review-workflow.org describes the whole workflow; this skill
is the contributor side of it.

## The operator does not read your output

Nobody reads your stdout. The result of a pass is what lands on the
list: a commit on your bookmark, pushed to `submissions`. Put every
answer, question, and caveat in mail.

## Layout

- `~/lab/default.jj` - trunk workspace, where patches are developed.
- `~/lab/mail.jj` - mail workspace; its `maildir/` is the list.
- `upstream` - canonical `trunk` and `mail`. Read-only to you.
- `submissions` - your outbox. Push your bookmark, named for your
  login, and nothing else. Pushing it never needs approval.

notmuch derives the tags from the list itself on every `notmuch new`:
your mail is `sent`, mail you answered with an In-Reply-To is
`replied`, and all other mail from others is `inbox`. Replying to a
message is what moves it out of your inbox.

## 1. Get up to date

Before any work, bring in everything that has landed since the last
pass, on both trunk and the list. Both workspaces share one repo, so
one fetch covers them:

    me="$(whoami)"
    cd ~/lab/default.jj
    jj git fetch --all-remotes

**Trunk.** Rebase your unmerged trunk work onto the new trunk. The
revset is your commits that are on neither branch upstream and not
part of your mail outbox:

    work='mine() ~ ::trunk@upstream ~ ::mail@upstream ~ mail@upstream::'
    jj rebase -s "roots(${work})" -d trunk@upstream --skip-emptied

Then settle what the rebase left:

- A patch Pat applied unchanged becomes empty and is dropped.
- A patch Pat applied with edits survives, now redundant. Find it by
  comparing your commits with trunk's log and the list (an "applied"
  reply, or its thread filed as accepted or merged), and abandon it
  with `jj abandon`.
- A conflicted commit (`jj log -r "conflicts() & mine()"`) must be
  resolved: `jj new <commit>`, fix the files, `jj squash`. If you
  posted it and it is still open, the series on the list is now stale;
  note that it needs a revised version.

When `jj log -r "${work}"` shows only open work, every commit is
conflict-free, and nothing landed is left, trunk is current.

**The list.** Base your outbox on the canonical list, dropping what
was accepted, then index the list together with your own pending mail
so messages you already answered count as replied:

    cd ~/lab/mail.jj
    if [ -z "$(jj log -r "bookmarks(exact:${me})" --no-graph -T 'commit_id')" ]; then
        jj bookmark create "${me}" -r mail@upstream
    fi
    jj rebase -b "${me}" -d mail@upstream --skip-emptied
    jj new "${me}"
    notmuch new

## 2. Pick the oldest inbox message

    id="$(notmuch search --sort=oldest-first --output=messages \
        --limit=1 tag:inbox)"
    thread="$(notmuch search --output=threads "${id}")"
    msgid="${id#id:}"      # the bare Message-ID, for headers

If there is none, the inbox is empty: stop without writing anything.

Every inbox message gets an answer, even if it is a short
acknowledgement. Replying is the only way a message leaves the inbox,
so an unanswered one blocks every pass after it.

## 3. Gather context with subagents

Run both in parallel with the Agent tool. They are read-only: they may
run notmuch, jj log/show, and read files, but must not write files,
move bookmarks, or create commits. Give each exactly this scope, and
have each return only the shape asked for.

**Thread reader.** Give it `${thread}` and `${id}`. It reads the whole
thread with `notmuch show --entire-thread=true --format=text
"${thread}"` and returns:

- what the target message asks of you, in one or two sentences;
- decisions, constraints, or corrections from later messages in the
  thread that change that ask (later messages win);
- patches in the thread, by subject and Message-ID, and their state as
  the thread describes it;
- open questions nobody has answered.

**List researcher.** Give it the target's subject, Message-ID, and the
key terms of its ask. It does two things.

First, it searches the rest of the list (subjects, bodies, and the
paths and commands the ask mentions) and returns at most ten related
messages, each as subject, Message-ID, and one line on why it matters,
plus any decision found elsewhere that constrains this work.

Second, if the target concerns a patch series, it finds every earlier
version: by `changeid:<id>` for each patch's change id, and by the
"Link to v(N-1)" lines in cover letters. It reads each earlier
version's whole thread, since that is where review happened, and
returns every review point raised there: who raised it, the subject
and Message-ID it was raised in, and whether the latest version
addresses it. Unaddressed points come first.

Read both results before deciding anything. A message elsewhere on the
list may already settle the question or redefine the task.

## 4. Do the work

Decide whether the message needs code changes, or only a reply.

For code changes, work in the trunk workspace on a fresh change:

    cd ~/lab/default.jj
    jj new trunk@upstream

Follow CLAUDE.md for commit messages and patch scope: one logical
change per commit, each message explaining why, and the series
self-contained against trunk. Test the change and review your own diff
before sending it. If you cannot finish, send a reply that says what
blocked you and what you need.

## 5. Post the series

Skip this step if the work produced no commits.

A patch series is its own thread on the list, never a reply to the
message that asked for it. It follows the Linux kernel's conventions,
less the archive links. Format it with
`~/lab/default.jj/libexec/mail/format-patch.sh`, which runs git
format-patch and gives each patch its commit's jj change id, as a
Change-Id header and a `change-id:` line under the `---`. The patches
come from the commit author, your address:

    cd ~/lab/default.jj
    base="$(jj log -r trunk@upstream --no-graph -T commit_id)"
    head="$(jj log -r @- --no-graph -T commit_id)"
    rm -rf /tmp/series
    ~/lab/default.jj/libexec/mail/format-patch.sh -o /tmp/series \
        --thread=shallow --base="${base}" \
        --to="<sender's From>" "${base}..${head}"

`--base` adds a `base-commit:` line naming the trunk commit the series
applies to. Always pass it.

**Cover letter.** For more than one patch add `--cover-letter` and
fill in its subject and blurb. Put the explanation of the work there,
or below the `---` line of a single patch.

**Prerequisites.** Base new work on trunk. If it truly needs another
unmerged series of yours, build on that series and format only your
own commits, with the prerequisite's head as the range start:

    ... --base="${base}" "${prereq_head}..${head}"

git then adds `prerequisite-patch-id:` lines for the commits between
trunk and the series. Name the prerequisite series in the cover letter
by its full subject, with its Message-ID in a footnote.

**Revisions.** For a revised series add `-v N`. Address every review
point the list researcher found unaddressed, or say why not. End the
cover letter blurb with what changed and a link to the previous
version:

    Changes in vN:
    - <what changed, and why>
    - Link to v(N-1): id:<message-id of the previous cover>

The change ids are unchanged across versions, so a reader can match
each patch to its earlier version with `notmuch search changeid:<id>`.

Note the series' subject and Message-ID from its first file, the cover
letter or the only patch, for the reply. A long Subject continues on
indented lines. Then deliver each file in order into the mail
workspace's maildir, which keeps the From as composed and adds a Date,
and commit the series on its own:

    for p in /tmp/series/*.patch; do
        ~/lab/default.jj/libexec/mail/maildir-deliver.sh < "${p}"
    done
    cd ~/lab/mail.jj
    jj diff --summary      # only "A maildir/..." lines
    jj commit -m "mail: Post [PATCH] <subject>"

## 6. Reply

Every pass ends with a reply to the message, even a short
acknowledgement, since replying is what moves it out of your inbox.
Start from notmuch's reply, which sets From, To, Subject, In-Reply-To,
and References, and quotes the message with an attribution line:

    notmuch reply --reply-to=sender "${id}" > /tmp/reply.eml

Add a Message-ID header, e.g.
`Message-ID: <$(date +%s).$(openssl rand -hex 6)@p7x.dev>`. Write the
body by CLAUDE.md's quoting rules: trim the quote to what you answer,
never reword it, and put each answer beneath the lines it answers.
Wrap at 72.

If you posted a series, summarize what it does and cite it by its full
subject with the Message-ID in a footnote, as CLAUDE.md describes, so
the reader can find it with `notmuch show`:

    The fix is posted as "[PATCH] jails: Add a README" [1].

    [1] id:<message-id of the series>

Cite any other message the same way. Then deliver and commit it on its
own:

    ~/lab/default.jj/libexec/mail/maildir-deliver.sh < /tmp/reply.eml
    cd ~/lab/mail.jj
    jj diff --summary      # only "A maildir/..." lines
    jj commit -m "mail: Reply to <subject>"

## 7. Push

The series and the reply are separate commits, so the moderator can
take or leave each. Point your bookmark at the last one and push:

    jj bookmark set "${me}" -r @-
    jj git push --remote submissions --bookmark "${me}"

## 8. Verify

Check the outcome from outside, not from what you printed:

    notmuch new
    notmuch search --output=tags "${id}"        # includes replied
    jj log -r "${me}@submissions" --no-graph -T commit_id
    jj log -r "${me}" --no-graph -T commit_id   # the same commit

If the message is not `replied`, the reply's In-Reply-To is wrong. If
the commits differ, the push failed. Fix it before stopping.

## Modes

- One pass: answer the oldest inbox message, then stop.
- Loop: repeat until step 2 finds an empty inbox.
