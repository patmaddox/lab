# Mail workflow

Agents submit patches to a mailing list; the maintainer pulls and
approves.  It works like Linux kernel development, except **git is the
transport instead of SMTP**.

## The idea

- The "mailing list" is a **maildir committed into git**.  Each message
  is a file; git moves, versions, and backs them up.  notmuch reads and
  threads them.
- **Patches are emails** -- `git format-patch` inline, applied with
  `git am`.
- No SMTP.  *Sending* a message means committing it to the maildir and
  pushing.  *Reading* means fetching and running `notmuch new`.

## Actors and repos

- The **maintainer** owns the canonical list: the `mail` bookmark in
  their repo.  They alone decide what it contains.
- Each **agent** publishes proposals under `claude/*` (e.g. the
  `claude/mail` bookmark) in its own repo, which the maintainer fetches
  read-only.
- Nobody writes anyone else's repo.  That is the trust boundary: the
  maintainer fetches an agent's `claude/mail`, reviews, and takes only
  what they accept.

## The maildir

- Lives in `mail/` (`mail/cur`, `mail/new`, `mail/tmp`).
- Maildir filenames are globally unique, so concurrent appends never
  collide; folding two feeds together is a clean union merge, never a
  rebase.
- Point notmuch at it (`database.mail_root`).

## Delivery agent

`libexec/mail/maildir-deliver.sh` is a sendmail-compatible program that
files one message into the maildir:

- It keeps the From the sender's mail config set.
- It adds a `Date` header if the message lacks one.
- The destination is `$MAILDIR`, else notmuch's configured mail root.

Two front ends feed it:

- **Composed mail** (a reply): message-mode / notmuch calls
  `maildir-deliver.sh` directly as its sendmail program.  A composed
  message already carries its Message-ID, Date, and threading, so
  nothing else is needed.
- **A patch series**: `libexec/mail/mail-send.sh <range>` wraps
  `git send-email --sendmail-cmd=maildir-deliver.sh`, which runs
  format-patch and threads the mails.  (Requires git send-email's
  `Email::Valid`.)

Either way the message lands in the maildir; commit and push to share.

## Agent side

1. Fetch the canonical list and base your work on it.
2. Compose either a **reply** to a message or a **patch series** from
   commits.
3. Deliver into the maildir (above).
4. Commit the new message(s) and push your `claude/mail`.
5. When the maintainer's list advances, rebase your proposal onto it and
   drop whatever was accepted.

Conventions:

- One message (or one series) per commit, so the maintainer can accept
  or reject at that granularity.
- A new revision of a series is a **fresh thread** subject
  `[PATCH vN]`, with a `v(N-1): <message-id>` link in the cover -- not a
  reply buried under the old thread.
- Append; never rewrite already-published history.

## Maintainer side

1. `jj git fetch` the agent's `claude/mail`.  Narrow that remote's
   refspec to `claude/*` so an agent's bookmark can never move your
   `mail`:

   ```
   [remote "inbox"]
       fetch = +refs/heads/claude/*:refs/remotes/inbox/claude/*
   ```

2. Review in notmuch: the "claude inbox" saved search and the
   `patch:new` / `patch:review` / `patch:waiting` / `patch:applied` /
   `patch:dropped` states.  Diffs are highlighted in notmuch-show; `E`
   edits a raw message.
3. To take a patch, `git am` it onto `trunk`.  To keep a message in the
   archive, cherry-pick it into `mail`.
4. To give feedback, reply on the list -- it threads under the patch and
   routes back to the agent (`to:claude`).  To decline, simply don't
   move `mail`.
5. Sign off and promote through your normal gate.  Agents never promote.

## Why this shape

- **git is the transport**: durable, backed up, works offline, no SMTP
  to configure or trust.
- **Unique maildir filenames** make the shared list conflict-free.
- **Per-actor repos** are the trust boundary: nothing an agent produces
  enters your tree without an explicit act on your side.
