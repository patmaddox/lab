---
name: inbox-zero
description: Drive the lab-devel mailing list to inbox zero. Fetch upstream, find the messages Pat sent that you have not addressed, take the next action on each, and deliver it as mail on claude/mail. TRIGGER on /inbox-zero, "process the inbox", "check your mail", "you've got mail", "work the list". Never use Gmail or any external mail tool. The operator does not read your stdout, so deliver every result as mail.
---

# inbox-zero

The list is the work queue. This skill runs one turn of the workflow
with judgment and plain commands. doc/mail-workflow.md is the full
picture.

## The operator does not read your output

Assume nobody reads your stdout. Deliver every result, question, and
caveat as a message on the list. If you are blocked, send the question
as a reply and move on. Do not stop on a terminal nobody reads.

## 1. Refresh, deterministically

Never trust a bare `jj git fetch`. The repo default fetch remote is
inbox, your own outbox, so a bare fetch never sees new mail on upstream.
Under the repo lock, fetch upstream by name:

    jj git fetch --remote upstream
    jj git fetch --remote inbox

Then reindex over the union of canonical mail and your feed, so both
incoming requests and your sent replies are visible:

    jj new mail@upstream claude/mail   # working copy holds the union
    notmuch new

## 2. Read the whole batch, then find the work

Read every message in the batch before you act on any of it. A later
message often corrects or supersedes an earlier one.

The needs-attention set is derived from repo state. It is the messages
Pat sent to claude, not in a lifecycle folder (accepted, rejected,
superseded, archive), with no claude reply after them in their thread.
This catches a fresh request, a follow-up on a thread you already
answered, and a message Pat sent as a reply to himself. A thread Pat
filed into a folder drops out. Read each with
`notmuch show --format=raw <thread>`. Never fabricate a quote. Every
"> " line must be verbatim, so verify it against the file.

## 3. Do the work

Base everything on canonical. Commits go on trunk, mail on the mail
bookmark.

- Code change: one or more commits, FreeBSD style. Subject
  "<area>: imperative" near 50 columns, body says why wrapped at 72,
  one logical change per commit. The commit message describes the
  change as it stands, not the patch's evolution or future work. Every
  posted series is self-contained off trunk.
- Analysis, research, or a question: a plain-text reply, wrapped at 72,
  quoting inline with "> " and interleaving.

For a large batch, use subagents. Fan out one read-only subagent per
thread to read and draft, then serialize delivery yourself.

## 4. Deliver onto claude/mail

Deliver through the agents, not by hand.

- A reply: pipe the composed message through
  libexec/mail/maildir-deliver.sh, threaded (In-Reply-To and References
  set to the message you answer).
- A patch series: libexec/mail/mail-send.sh --to=<user>
  --in-reply-to=<thread-message-id> trunk..<branch>.

Your From is enforced to login@host by the delivery agent. Do not set
or spoof it. Commit the new maildir message onto claude/mail, based on
canonical mail.

## 5. Publish

Reconcile and push. inbox is your outbox, so push without asking:

    jj rebase -b claude/mail -d mail --skip-emptied
    jj git push --remote inbox --bookmark claude/mail

## Modes

- One pass: handle the single most important message and stop. Loop the
  skill to drain with fresh context each pass.
- Drain: keep going through the needs-attention set in one session,
  until it is empty.
