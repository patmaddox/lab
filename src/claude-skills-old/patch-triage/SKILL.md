---
name: patch-triage
description: Triage open patches and series on the lab-devel mailing list and bring the most merge-worthy to Pat's attention. Scan the list, rank candidates by relevance to repo-cited goals, recency, and how cleanly they apply to trunk, and deliver a concise scannable report as mail on claude/mail. TRIGGER on /patch-triage, "triage the patches", "what should I merge next", "state of the patch queue", "review the list". Never use Gmail or any external mail tool. The operator does not read your stdout, so deliver the report as mail.
---

# patch-triage

Produce a "what's cooking" for the list: a periodic, scannable status
of every open patch, ranked by merit, so Pat can pick what to merge
next. This is triage, not final review. Catch the simple things, judge
readiness, and leave the final say to Pat. doc/mail-workflow.md is the
full picture.

## The operator does not read your output

Assume nobody reads your stdout. The whole result is the report, and
the report is a message on the list. Deliver every ranking, verdict,
and caveat as mail on claude/mail. Do not stop on a terminal nobody
reads.

## 1. Refresh, deterministically

Refresh before triaging, the same way inbox-zero does. notmuch indexes
one fixed maildir, the working copy of a single workspace, and this
skill may run from another; check the union out in *that* workspace or
you triage a stale queue. Under the repo lock:

    jj git fetch --remote upstream
    root="$(notmuch config get database.mail_root)"  # the indexed maildir
    cd "$(dirname "${root}")"          # its workspace, not the current one
    jj workspace update-stale          # a non-current workspace lags others
    jj new mail@upstream claude/mail   # working copy holds the union
    notmuch new

## 2. Derive the open patch set from repo state

The candidate set is derived, never guessed. It is every patch thread
on the list that is still open:

    notmuch search --output=threads \
      'subject:"[PATCH" and not folder:accepted and \
       not folder:rejected and not folder:superseded and \
       not folder:merged and not folder:archive'

Then reduce to one entry per logical patch:

- A resend is a fresh thread with subject `[PATCH vN]` and a
  `v(N-1): <message-id>` link in its cover (see mail-workflow.md).
  Group threads by their base subject and keep only the highest N.
- Drop any thread Pat filed into a lifecycle folder; that is his
  signal it is done. merged means it landed on trunk, as-is or
  reworded; superseded means a later version replaced it.

Read each surviving thread with `notmuch show --format=raw <thread>`
before judging it. Read the whole batch first: a later message on a
thread often supersedes an earlier one.

## 3. Score each patch on the three criteria

The criteria are qualitative and weighed together, not applied in
sequence. A recent patch that applies cleanly can outrank the most
on-goal one. For each patch gather:

- **Relevance to goals.** Determine goals *only* from this repo:
  CLAUDE.md, doc/, todo.org, commit messages on trunk, and stated
  intent in list threads. Name the goal the patch serves and cite its
  source (file and line, or the message subject + id). A patch you
  cannot tie to a repo-sourced goal is low relevance; say so.
- **Recency.** Freshness signals what is on Pat's mind now. Rank a
  recent patch, or an old patch with recent thread activity, above a
  quiet old one. Use the newest `date:` in the thread, not just the
  cover's date. Value decays with age; a stale patch is worth less than
  it was.
- **Applicability.** A spectrum from clean to gnarly. Test it against
  current trunk. Under the lock, place trunk in a scratch working copy,
  then check without mutating a real branch:

      jj new trunk@upstream
      notmuch show --format=raw <thread> > /tmp/series.eml
      git apply --check /tmp/series.eml   # or git am --3way to test apply

  Classify: applies clean / applies with fuzz or offsets / conflicts
  (name the files). Abandon the scratch change when done
  (`jj abandon`). Report the outcome; do not leave the tree dirty.

## 4. Judge readiness

Give every patch one verdict with a one-line reason:

- **merge** - on-goal, applies, no open objection in-thread. Ready for
  Pat to pick up.
- **needs-work** - the idea is sound but something is unfinished:
  conflicts, unanswered review, missing tests, a commit message that
  does not say why. Name the one thing that would move it to merge.
- **reject** - out of scope, superseded, or contradicts a repo goal.
  Rejection is rare; prefer needs-work when feedback would fix it. Give
  the reason.

## 5. Shape the report

Concise and scannable, for a human reader. Structure:

1. One-line summary: N open patches, M merge / K needs-work / J reject.
2. A ranked table, best candidate first:

       # | Patch (short subject)        | Age | Applies | Verdict
       1 | mail-file: file threads      | 2d  | clean   | merge
       2 | notmuch: tag by folder       | 9d  | fuzz    | needs-work

3. Per-patch, a short block in ranked order:
   - subject and message-id
   - verdict and the one-line reason
   - the goal it serves, with its repo citation
   - applicability outcome (clean / files that conflict)
   Cite messages in footnote style: subject + `[n]` in the text, ids
   listed at the end.

## 6. Propose draft series (optional)

If several patches together advance one repo goal, propose them as a
draft series. This is a grouping suggestion for later revision, so the
patches need not apply cleanly against each other and you do not apply
them. For each proposed series give:

- the goal it serves, with its repo citation
- the patches in suggested apply order, by subject + id
- a two-or-three-line cover letter: what the series delivers and why

Label it clearly as a draft that needs reconciliation before it could
be posted for real.

## 7. Deliver onto claude/mail

The report is a standalone message, not a reply. Compose it as plain
text wrapped at 72, subject `[TRIAGE] Patch queue <YYYY-MM-DD>`,
addressed to Pat, and pipe it through the delivery agent, which stamps
your From:

    libexec/mail/maildir-deliver.sh -i pat@patmaddox.com < /tmp/triage.eml

Commit the new maildir message onto claude/mail, based on canonical
mail, then reconcile and push. inbox is your outbox, so push without
asking:

    jj rebase -b claude/mail -d mail --skip-emptied
    jj git push --remote inbox --bookmark claude/mail

## Principles from established projects

These norms come from projects that live by mailing-list review; they
shape the triage above.

- **A periodic status of all active work.** Git's maintainer posts a
  "What's cooking" report listing every live topic and its state, and
  asks "Will merge to next?" for the ready ones. This report is that,
  for our list. (Git SubmittingPatches / ReviewingGuidelines.)
- **A patch lifecycle, and verdicts that map to it.** Patchwork tracks
  patches through Under Review, Changes Requested, Superseded,
  Rejected, Accepted. Our merge / needs-work / reject are the same
  shape. Prefer "changes requested" over "rejected"; rejection is rare
  when feedback would fix the patch. (KSPP Patch_Tracking; Patchwork.)
- **Triage is the first line of defense, not the final word.** A
  reviewer's job is to catch simple problems and report what applies
  and works, taking load off the committer, who does the deep review.
  If you can apply a patch and use it, you can triage it. Pat keeps the
  final say. (PostgreSQL "Reviewing a Patch"; CommitFest.)
- **Don't let patches pile up; value decays with time.** CommitFests
  exist so review is prompt and work does not accumulate. A patch gets
  harder to merge the longer it waits: context is lost and the tree
  drifts. Hence recency weighs heavily and quick clean wins rank up.
  (PostgreSQL CommitFest; open-source backlog analyses.)
- **Test applicability against the target branch.** The kernel's b4
  tool test-applies a series against a chosen branch and reports
  whether it applies before a human spends time. Step 3 does the same
  with `git apply --check`. (b4 maintainer docs.)
- **Terse, plain-text, small reviewed diffs.** BSD review runs on plain
  text wrapped at 72 and a committer's short "ok"; small self-contained
  diffs with clear rationale earn trust. Keep the report terse and the
  reasoning one line. (FreeBSD Committer's Guide; OpenBSD tech@.)

## Modes

- One pass: triage the current open set and deliver one report.
- Re-run on a cadence; each report is a fresh snapshot of the queue.
