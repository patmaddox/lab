---
name: revise-prose
description: >
  Decide where each idea in a change's prose belongs, in the commit
  message, the docs, or a comment, so that it is written once, where
  a human reader will look for it. Use when writing or revising a
  commit message, docs, or comments that explain why or how, and when
  an explanation could sit in more than one of them. Works with the
  commit-message and repo-docs skills. To reconcile the messages,
  docs, and comments of a series of commits, use the prose-editor
  agent.
argument-hint: "[revision-range]"
---

# revise-prose

Each idea gets one home. A commit message, a doc, and a comment each
reach different readers at different times, and each costs something
to keep. No home ranks above another. For each idea, judge where the
human reader who needs it will look, and write it there, in the form
that serves that reader best.

When invoked by hand with a revision range, such as
`/revise-prose origin/trunk..HEAD`, hand the range to the
prose-editor agent, which reconciles the messages, docs, and comments
of those commits by this rule. Report what it returns. Invoked with
no range, this skill only loads the rule. The prose-editor agent
itself ignores this paragraph.

## The homes

- **Commit message.** Read by a reviewer judging the change, and
  later by someone who traces a line with blame or reads the log. It
  is fixed to one change, so it never goes stale, and it costs no
  other reader anything. But users never see it, and it cannot be
  corrected once published. Only a reader who digs finds it, through
  blame, and moving or reformatting the code can hide it from blame.
  It suits what makes sense only against the tree before the change:
  the status quo and its problem, why to change it now, alternatives
  rejected for this change, and what the change leaves unaffected. It
  also suits the reason for a small choice that only someone tracing
  that line would ask about.
- **Docs.** Read by someone using, learning, or maintaining the tree
  as it stands: READMEs, man pages, guides. A reader finds them
  without opening the code or the log. Every later commit must keep
  them true, and every reader pays for their length. They suit what a
  thing is, how to use it, facts to look up, how the parts fit
  together, and design decisions a user or maintainer would question.
  Where the repo keeps them, they also suit notes on changes that
  users must act on, such as upgrade notes or a man page's HISTORY
  section.
- **Comments.** Read by everyone who edits that code, at the line in
  front of them. Like docs, they must be kept true, and they crowd
  the code they sit in. A docstring is the reference for an interface
  at its declaration: what it does, its inputs, outputs, errors, and
  side effects. Other comments suit why a piece of code is as it is,
  when the code cannot say so and its editor would go wrong without
  knowing, including an alternative that editor would otherwise try.

Some ideas belong nowhere. The code or the diff already says them, or
no reader needs them.

## Choosing

Where an idea sits now is no evidence of where it belongs. Existing
prose may have been misplaced from the start, and a long message or
a doc section tends to attract more of the same, because adding to
it is easy. When revising, take each idea out of its current place
first, and place it as if it had no home yet. Then rewrite it in the
form its new home needs, rather than carrying its old wording over.

Weigh each idea against all three homes, and against cutting it.
These questions help, in any order. None of them decides alone.

- **Who needs it, and what are they doing then?** Each of these
  readers looks in a different place: a reviewer judging the change,
  a user of the tree, a maintainer learning how it fits together,
  someone editing one function, and someone tracing why a line
  changed.
- **Is it the story of this change?** An account of how the tree got
  here, which makes sense only against the tree before it, suits the
  message. Docs and comments describe the tree as it stands. Words
  like "no longer", "now", "previously", and "instead of" often mark
  such a story, but check the idea, not the word: "uses kqueue
  instead of select, which caps descriptors" describes the tree. A
  removed flag that users must stop passing may also belong in the
  docs' upgrade notes, if the repo keeps them.
- **How many readers need it?** An idea that most readers of the tree
  need belongs where they look without digging, in the docs or a
  comment. An idea that only a reader tracing one change will ask for
  can wait in the message, where it costs everyone else nothing.
- **What is its scope?** One function's contract, or the reason for
  one surprising line, goes beside that code. How to use a thing, a
  design that spans files, or a decision about the whole goes in the
  docs. A reason tied to this change alone goes in the message.
- **Does the diff already show it?** The diff includes its code, doc,
  and comment hunks. A message that summarizes the docs it adds
  restates the diff, and a comment that restates the code repeats it.

A design decision's reasons have no fixed home. Put them where the
reader who would question the decision looks: in the docs if they
would question it while using or learning the tree, in a comment if
while editing that code, and in the message if only someone tracing
the change would ask.

Then choose its form in that home: a subject, a clause, a paragraph,
a docstring, a line comment, a doc section, a list, or a table. Use
the smallest form that carries the idea to its reader.

## When to say it twice

Say an idea twice only when two readers each need it where they are,
and keep the second copy to a clause or a pointer:

- The subject may name what the commit documents or changes, though
  the docs or the diff say it too.
- Where one home argues a reason in full, another may name it in a
  clause so that it reads on its own, or point to it. It does not
  argue the reason again.
- A warning about destructive or surprising behavior goes wherever
  each reader would be hurt by missing it: the docs for users, a
  comment at the dangerous code for its editors, and the message for
  the reviewer who must judge it.

A paragraph in one home that a paragraph in another could replace is
duplication. Keep the copy its reader would look for, and cut the
other.

## Signs of misplaced prose

Each sign marks prose whose reader looks somewhere else. Move it
there, or cut it.

- A message that restates its commit's docs or comments, such as a
  list of the sections, options, or rules they spell out, or how to
  install or use what the commit adds. Replace it with what the diff
  cannot show, such as the status quo and its problem.
- Docs or comments that narrate change: "now supports", "was changed
  to", "no longer", "new in this version", "fixed bug". Move it to
  the message, or cut it. A change users must act on may stay in
  upgrade notes or a HISTORY section, where the repo keeps them.
- Docs or comments that argue what only a reviewer of this change
  would ask about: why it was done now, what it leaves unaffected, or
  an alternative no one would propose again. Move it to the message.
- A comment that justifies a routine choice no editor of that code
  would question. Cut it, or move it to the message.
- A design decision argued in full in two places. Keep the full
  argument where its reader looks, and shrink the other to a clause.
- A design decision that a user or maintainer would question while
  reading the tree, argued only in a message. Move it to the docs or
  a comment, and leave a clause in the message.
- A message that explains a quirk of the code, a constraint, or a
  trap that an editor needs at the line. Move it to a comment.
- A message that explains how to use what the commit adds, when the
  tree has no docs that say so. Move it to the docs.
- A comment that explains how to use a thing, or a design that spans
  files. Move it to the docs, and leave a pointer in the code only if
  an editor of that code needs one.
- Docs that explain the quirk of one line, which an editor of that
  line would never see there. Move it to a comment beside the line.
