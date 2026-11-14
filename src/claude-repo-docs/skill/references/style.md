# Sentences

These rules shape each sentence once its idea has a home. They take
the sentence rules of Simplified Technical English (ASD-STE100) and
of plain-language guides, and leave out its fixed dictionary and
hard limits, which cost facts in prose about code. They also target
habits that mark text written by a language model. The repo's own
conventions win where they differ. Apply the rules as judgment: a
sentence that breaks one and reads well stays.

## One name per thing

Call each thing by one name throughout, the name the code uses. A
second name makes the reader wonder whether it is a second thing, so
don't vary words for style. Treat an identifier as a noun, and don't
make it a verb: "map the file with `mmap()`", not "mmap the file".

## Actors as subjects, actions as verbs

Make whatever acts the subject, and put what it does in the verb.
"Perform validation of the input" becomes "validate the input". A
clause tacked on with ", making…", ", resulting in…", or ",
ensuring…" hides a consequence and whom it hits:

- Before: Claude sends new versions without interdiffs, making it
  hard to see what changed.
- After: Claude sends new versions without interdiffs, so a reviewer
  cannot see what changed.

Passive voice is fine when the actor is unknown or does not matter.

## Old before new

Start a sentence with what the reader already knows, linked to the
sentence before, and end it with the new point, where readers look
for emphasis. Keep one subject through a paragraph where the content
allows.

- Before: Later syncs fail with "Unable to recover from UIDVALIDITY
  change" when the maildir moves, because the state no longer
  matches it.
- After: When the maildir moves, its sync state no longer matches
  it. Every later sync then fails with "Unable to recover from
  UIDVALIDITY change".

## Whole sentences

Keep "that", "which", and articles. Commit messages and comments are
prose, not notes: "Fails if file missing" becomes "It fails if the
file is missing." Prefer one verb to a phrasal verb ("learn", not
"find out"), except in established terms such as "set up" and "look
up". Contractions are fine. Address the reader as "you" only where
the repo's docs do, and never in a man page.

## Length

A sentence over about 25 words, or over 20 in a step, often holds
two ideas. Split it if it splits cleanly, but don't break a "because"
or "so" chain into fragments that lose the link. Don't join sentences
with semicolons. Put at most three nouns in a row: "the package build
cache directory" becomes "the directory that caches package builds".

## Prose for reasons, lists for items

An explanation is a chain of reasons, so write it as prose and keep
the connectives: because, so, but, unless. Use a list for parallel
items or for steps, and let each item complete the line that
introduces it. Don't open items with bold labels unless the repo's
docs do.

## Plain words, said once

State real uncertainty once, where it applies, and say what is
unknown. Cut hedges and intensifiers: "simply", "basically",
"really", "truly", "actually", "quite". Cut words that sound weighty
and add nothing: "leverage", "robust", "seamless", "comprehensive",
"crucial", "serves as". Prefer the short word: "use", not "utilize".

## Nothing lost

After tightening, compare the new text with the old. Every fact,
condition, qualifier, and warning must survive. A simpler sentence
that drops "unless the jail is running" is wrong.
