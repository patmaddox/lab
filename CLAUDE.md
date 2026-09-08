# lab.jj

## System

FreeBSD host. Use BSD variants of tools - do not assume GNU flags.
When unsure, check `man <tool>`.

## Version Control

This repo uses jj (Jujutsu), not git.

Use `jj commit -m` to commit after successful work. Do not commit
after errors. Never run `just promote` or `promote.sh`.

Only modify `mutable()` commits. Always use `--git` with `jj diff`
and `jj show`.

### Concurrency lock

Multiple Claude sessions share the same working copy. Wrap all jj
commands for a turn in a single lockf invocation:

    lockf -k "$(jj root)/.jj/claude.lock" sh -c '
      jj squash --into foo
      jj log -r ..@ --no-graph -n 5
    '

Scripted sessions use `libexec/just/claude-run.sh` which handles
locking automatically.

### Commit messages

FreeBSD style. Subject ~50 chars, imperative mood, prefixed with
`<area>: ` where area matches the subdirectory. Body wrapped at
72 chars - explain why, not what. No Co-Authored-By trailers.

Good body: "Cloning prints a detached HEAD advisory and progress
           info that clutter handler output, making errors harder
           to spot."
Bad body:  "Set advice.detachedHead=false on the clone command and
           pass -q to suppress all clone noise."

The diff already shows what changed. The body should say why it
matters.

## Mail

The lab-devel mailing list is the primary channel for work. It is a
maildir committed to jj on the `mail` bookmark and read with notmuch;
"mail", "email", "your mail", "the inbox", "the list", and "check
your mail" all mean this list. They never mean Gmail or any Google or
other external mail service - do not reach for those tools here.

Two remotes, two directions. You **pull from `upstream`** (canonical
`trunk` and `mail`; read-only to you) and **push to `inbox`** (your
outbox). `inbox` is yours to push freely - the maintainer only reads
from it and merges what they accept - so publishing your `claude/*`
bookmarks there is expected and never needs approval:

    lockf -k "$(jj root)/.jj/claude.lock" \
        jj git push --remote inbox --bookmark claude/mail

To act on the list, use the `check-mail` skill (`claude-mail-run` is
the headless equivalent). One pass takes the single most important
open thread - a message addressed to you with no reply yet - does the
work, submits the result onto `claude/mail`, pushes to `inbox`, and
starts fresh. Loop it to drain the queue, or keep going within one
session when context should carry across threads. doc/mail-workflow.md
has the full picture.

## Own the loop

Never take control signals from a coding agent's output. A tool that
reads its own control tokens back from that output will misfire,
because model output is not deterministic. This is what broke sclr. It
read the string sclr:done from stdout, and while working on its own
prompts the model repeated that string, so sclr stopped early.

What we want is a loop whose control never depends on what the model
happened to print. The result of a turn should be visible from outside
the model, in a place the model can only change by taking a real
action.

So pipe agent output to /dev/null, and key control on side effects you
can check. Look for a signal file, a commit, a moved bookmark, a
delivered message. Check for the positive fact, e.g. "report.org
exists" or "the commit landed", not a parsed string. The channels you
can trust are the ones the model does not author, i.e. the exit code,
the filesystem, and the VCS state. If a turn must hand back data, have
the model write it to a named file with a known shape, then validate
that file.

## Quoting in replies

When you reply to a message on the list, quote it the way every mail
client does. Do not paraphrase what someone wrote. Quote it.

Open with an attribution line, e.g. "On <date>, <name> wrote:". Prefix
every quoted line with "> ". Interleave your responses beneath the
lines they answer, so the thread reads point then answer, top to
bottom. Do not top-post. Trim the quote to the parts you actually
answer, and never reword the text you keep. Your own words carry no
"> " prefix.

## Read the whole batch before working

When you fetch new mail, read every message in the batch before you
start any work. Replies come in batches, and a later message often
changes an earlier one. It may correct it, supersede it, or add the
context the earlier one lacked. Work the first thread before reading
the rest and you spend effort on a task the batch has already redefined.

Read the batch, find the messages that constrain the others, then work.

## Commit messages describe the patch, not its history

A patch stands alone, and so does its commit message. Write the message
to describe the change as it stands, or the before and after of applying
it.

Do not describe the evolution of the patch itself. Phrases like "rewrap
the earlier version" or "unchanged from v1" point at a version that is
lost once history is rewritten, so they describe nothing the reader can
see. Do not refer to work later in a series, or to patches not yet sent.
A reader with only this commit must understand it in full.

You may refer to earlier commits that are already in the tree. When you
revise and resend a patch, write the message as if this were the first
and only version. Version notes and interdiffs belong in the cover
letter, not in the commit.

## Citing messages

When you refer to a message, thread, or patch, name it so the reader can
find it and knows what it is. Give the full subject, never elided, in
the text. Put the Message-ID in a footnote, not inline, because inline
ids wreck the prose.

Use footnote style. In the text, write the subject and a marker like
[1]. At the end, list each marker with its id:

    The delivery series [1] is accepted and ready to apply.

    [1] id:cover.1788793203.git.claude@lab-claude.p7x.dev

The reader finds any cited message with notmuch show id:MESSAGE-ID. A
reference with only an id and no subject is worse than useless, because
the reader can find it but cannot tell what it is without opening it.

## Patches

Development is hybrid trunk-based and distributed. Trunk is canonical
and Pat keeps it close to linear. Many useful patches live only on the
list, on upstream, and on your inbox. Use them freely in your own tree.
Not being on trunk does not mean you cannot build on it. You manage
your own workspace.

Every series you post must be self-contained. It carries only its own
new behavior, never another unmerged series it happened to build on.
Merge whatever prerequisites you need in your own tree. A local
mega-merge is one possible future timeline. The series you post is the
delta Pat can apply onto trunk. If new work truly needs a prior patch,
say so and reference it, or include those commits on purpose.

b/dev is Pat's local mega-merge. Treat it as reference only. It is more
mature than a random list patch, but it is subject to revision. Do not
assume its patches land as-is, and do not base posted work on it.

## Use subagents for large batches

When you face a large batch of independent work, e.g. many open threads
in the mailbox, use subagents. They keep the main context clean and let
the work run in parallel.

Spawn one read-only subagent per thread or item. Each has its own
context window and returns only a short result, so intermediate output
does not pollute the main thread. Give each a tight scope. Say what it
gets, what question it answers, and what shape the result takes.

Do the reading, research, and drafting in the subagents. Then serialize
the writes in the parent. This matters most when the work changes
shared state, such as the jj working copy or the feed. Parallel reads
are safe. Parallel writes corrupt. Fan out to draft, then deliver in
order from one place.

## Behave like an effective contributor

Act like a trusted contributor on a well-run open-source project. The
goal is to make the maintainer's and reviewers' jobs easy. Spend your
own effort so they spend less of theirs. That is what earns trust and
latitude.

Propose by patch, one logical change at a time. Keep each change small
and self-contained, and keep the tree working after each step. Write a
commit message that explains why the change matters, detailed enough to
judge without reading the diff. If the message sprawls, split the
commit. Review your own diff as carefully as the code before sending
it.

When you hit a problem, reproduce it and bring a proposed fix, not just
a complaint. Give exact steps, what you expected, and what differs.
Read the existing code and history before asking, and show that you
did.

Respond to review promptly and without ego. Address every point or
explain why not, and say thanks. You may disagree with reasons, but
once Pat decides, commit to the decision and record the reasoning.
Respect his time and his final say on what gets merged. Leave the tree
better than you found it.

These norms are consistent across the projects we most resemble. The
Linux kernel, Git, and PostgreSQL all optimize for reviewer effort. The
BSDs do too. The FreeBSD Committer's Guide stresses small reviewed
commits and respect for maintainers, style(9) enforces one house style,
and OpenBSD's tech@ culture expects terse, well-reasoned diffs sent to
the list. Small clean patches, clear rationale, and doing your homework
are how each of them earns trust.
