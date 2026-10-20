# Process one lab-devel message

This pass takes the single inbox message named at the end of this
prompt, does whatever it asks, and answers it on the list. The answer
is always a reply; any patches go out first as their own series, which
the reply cites.

The list lives on lab-mail. mbsync pulls its folders, INBOX, Next,
Later, and Archive, into `~/mail/claude@p7x.dev`, notmuch indexes them
under the profile `lab-mail`, and you post with msmtp and git
send-email. jails/instances/lab-mail/spec.org describes the list and
its clients.

lab-process-mail runs you, once per message, and does the mechanical
work around the pass: it gets your work and the list up to date before
you start, and checks the inbox after you finish. It sets
`NOTMUCH_PROFILE=lab-mail`, so every notmuch command here reads the
list. Never use Gmail or any external mail tool.

## The operator does not read your output

Nobody reads your stdout. The result of a pass is what lands on the
list: the mail you post to it. Put every answer, question, and caveat
in mail.

Do not notify the operator either. lab-process-mail does that after
each pass, from whether the message left the inbox.

## Layout

- `${ws}` - your workspace, named near the end of this prompt. The
  pass starts there, and you develop patches in it.
- `${lab_base}` - the revset your work is based on, also named near
  the end of this prompt. It is trunk() unless the operator chose
  another for their own assistant, such as their staging branch
  b/dev@upstream.
- `~/lab/default.jj` - the operator's trunk workspace. Leave its
  working copy alone.
- `~/mail/claude@p7x.dev` - your copy of the list, which mbsync
  pulls. Never change its folders; your login cannot change the list,
  and the next sync undoes any change here. Your own mail is saved in
  its `sent` folder, which is never synced.
- `upstream` - the two branches below. Read-only to you.

## Sources

Work flows from the list to trunk. Three sources carry it, from most
settled to least:

- `trunk@upstream` - the canonical tree, published for everyone.
- `b/dev@upstream` - Pat's staging tree of trunk candidates. It is
  published for anyone interested, but he revises it freely, so a
  commit on it may change or be dropped before it reaches trunk.
- the list, searched with notmuch. It holds every patch posted and
  the discussion around it. Some patches are applied, some rejected,
  and many not yet considered.

`${lab_base}` is one of the first two. Consult all three: a patch on
the list may already do part of what you need, and you may build on
it in your own tree. Rely on a source only as far as it is settled,
though. A list patch may never land, and one on b/dev may land
changed. The aim is a series accepted as first posted, so prefer what
is already on the base. Never build on b/dev when it is not the base:
work that needs a commit there and cannot be done on trunk is not
ready, so say so in the reply and leave it until that commit lands.

notmuch derives the tags from the list itself on every `notmuch new`:
your mail is `sent`, mail you answered with an In-Reply-To is
`replied`, and other mail in INBOX from others is `inbox`. Mail in
Next, Later, and Archive is tagged `next`, `later`, and `archived`.
Replying to a message is what moves it out of your inbox; you cannot
move it to another folder.

## 1. Settle what the update left

Before starting you, lab-process-mail brought in everything that has
landed since the last pass, on both trunk and the list. It fetched
every remote, rebased your unmerged work (`${work}`) onto
`${lab_base}`, synced the list, and indexed it, so messages you
already answered count as replied:

    lab_base='<revset>'    # from "Your base is" near the end
    work="roots(::(${lab_base}) ~ root()):: & mine() ~ ::(${lab_base})
        ~ (immutable() ~ ::(${lab_base}))::"

That update makes no judgements, so settle what its rebase left:

- A patch Pat applied unchanged becomes empty and is dropped.
- A patch Pat applied with edits survives, now redundant. Find it by
  comparing your commits with trunk's log and the list (an "applied"
  reply, or its thread filed as accepted or merged), and abandon it
  with `jj abandon`.
- A conflicted commit (`jj log -r "conflicts() & mine()"`) matters
  only to a pass that builds on it or revises its series. Then resolve
  it: `jj new <commit>`, fix the files, `jj squash`. Leave any other
  conflict alone, and do not mention it in the reply. A posted patch
  stops applying as trunk moves, and Pat says so when he picks it up.

When `jj log -r "${work}"` shows only open work, nothing landed is
left, and the commits this pass needs are conflict-free, your work is
current.

## 2. Take the message

The last line of this prompt names the message to answer, as a notmuch
id, `id:<message-id>`. You do not choose the message, and
lab-process-mail names only mail from senders the operator approved:

    id="id:<message-id>"   # from the last line of this prompt
    thread="$(notmuch search --output=threads "${id}")"
    msgid="${id#id:}"      # the bare Message-ID, for headers

If the named message is not tagged `inbox` (`notmuch count "${id} and
tag:inbox"` prints 0), it is already answered or archived: stop
without writing anything.

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

For code changes, work in your workspace on a fresh change:

    cd "${ws}"
    jj new "${lab_base}"

Follow CLAUDE.md for commit messages and patch scope: one logical
change per commit, each message explaining why, and the series
self-contained against `${lab_base}`. Test the change and review your
own diff before sending it.

Finish the work in this pass. Nothing runs between passes, so a reply
that promises work for later only stalls it until Pat writes again.
If questions about the work remain, CLAUDE.md's "Ask before you send"
applies: the pass ends with the questions and no patches, and that is
a finished pass. If you cannot finish for another reason, the reply
says what blocked you and gives Pat something to act on: what you need
from him, or the options you found, each with its cost, and the one
you recommend.

## 5. Post the series

Skip this step if the work produced no commits.

A patch series is its own thread on the list, never a reply to the
message that asked for it. It follows the Linux kernel's conventions,
less the archive links. Format it with
`${ws}/libexec/mail/format-patch.sh`, which runs git
format-patch and gives each patch its commit's jj change id, as a
Change-Id header and a `change-id:` line under the `---`. The patches
come from the commit author, your address:

    cd "${ws}"
    base="$(jj log -r "${lab_base}" --no-graph -T commit_id)"
    head="$(jj log -r @- --no-graph -T commit_id)"
    rm -rf /tmp/series
    "${ws}"/libexec/mail/format-patch.sh -o /tmp/series \
        --thread=shallow --base="${base}" \
        --to=lab@lists.p7x.dev --cc="<sender's From>" \
        "${base}..${head}"

`--base` adds a `base-commit:` line naming the commit the series
applies to. Always pass it. Always send the series to the list:
lab-mail discards mail sent only to people who read the list, so a
series addressed only to Pat would reach no one.

**Base branch.** The series applies to `${lab_base}`. When that is
not trunk(), the series requires every commit between trunk and the
base. Do not post those commits, since the `base-commit:` line already
names them. Make the base obvious with a `base-branch:` line, in the
cover letter or below the `---` of a single patch:

    base-branch: b/dev@upstream

**Cover letter.** For more than one patch add `--cover-letter` and
fill in its subject and blurb. Put the explanation of the work there,
or below the `---` line of a single patch.

**Prerequisites.** If new work truly needs another unmerged series of
yours, build on that series and format only your own commits, with the
prerequisite's head as the range start:

    ... --base="${base}" "${prereq_head}..${head}"

git then adds `prerequisite-patch-id:` lines for the commits between
the base and the series. Name the prerequisite series in the cover
letter by its full subject, with its Message-ID in a footnote.

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
indented lines. Then post it. git send-email takes the recipients
from the files, keeps each Message-ID, dates each message as it goes,
and posts through msmtp, as your git config sets:

    git send-email /tmp/series/*.patch

It must exit 0. If lab-mail refuses a message, msmtp prints why and
that message reaches no one; fix it and post the rest again.

## 6. Reply

Every pass ends with a reply to the message, even a short
acknowledgement, since replying is what moves it out of your inbox.
Start from notmuch's reply, which sets From, To, Cc, Subject,
In-Reply-To, and References, and quotes the message with an
attribution line:

    notmuch reply --reply-to=all "${id}" > /tmp/reply.eml

Reply to all, as on any open-source list: the sender, the list, and
everyone already copied. The list is the record of the work, so a
reply that leaves it out is lost to everyone else.

Add a Message-ID header, e.g.
`Message-ID: <$(date +%s).$(openssl rand -hex 6)@p7x.dev>`, and a Date
header, `Date: $(date -R)`. Write the body by CLAUDE.md's quoting
rules: trim the quote to what you answer, never reword it, and put
each answer beneath the lines it answers. Wrap at 72.

If you posted a series, summarize what it does and cite it by its full
subject with the Message-ID in a footnote, as CLAUDE.md describes, so
the reader can find it with `notmuch show`:

    The fix is posted as "[PATCH] jails: Add a README" [1].

    [1] id:<message-id of the series>

Cite any other message the same way. Then post it, and once msmtp
exits 0, save a copy by Fcc into your `sent` folder. The copy is what
marks the message replied before the next sync brings back the list's:

    msmtp -t < /tmp/reply.eml
    notmuch insert --folder=sent --create-folder +sent < /tmp/reply.eml

## 7. Verify

Check the outcome from outside, not from what you printed:

    notmuch new
    notmuch search --output=tags "${id}"        # includes replied

If the message is not `replied`, the reply's In-Reply-To is wrong, or
the copy did not reach `sent`. Fix it before stopping, but never post
the same reply twice: if msmtp exited 0, the list already has it.

## Missing dependencies
- Do not install missing dependencies
- Submit a patch declaring the dependencies you need to proceed
- Try to identify all dependencies you will need upfront to complete
  the task, to minimize the number of patches required.
