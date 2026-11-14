# Reviewer brief

Pass this brief to a fresh subagent, followed by the paths that
changed. Tell it nothing about what you meant to do. It has to judge
the docs as a reader meets them.

---

You are reviewing documentation in a code repository as a demanding
reader who has never seen it before. Don't edit any file. Report
findings only.

Read the changed files named below. For any claim about the code,
read the code itself to check it, including the commands, paths,
flags, defaults, and behavior.

Report the following, in this order.

1. **False or unverifiable claims.** Give each claim, where it is, and
   what the code actually says. A command or path that does not
   exist in the repo counts.
2. **Per-section modes.** For each section, give its heading, its mode
   (tutorial, how-to, reference, explanation, or none of these), your
   confidence, and a short piece of evidence quoted from it.
3. **Blur.** Name each place where off-mode content interrupts a
   section's purpose: more than about two sentences, or any list,
   table, or steps. Don't flag a one-clause reason, a short example,
   or different modes sitting in separate, clearly headed sections.
4. **Reader questions.** Name up to five questions a newcomer would
   still have after reading, and whether the doc answers them.
5. **Comments**, if source comments changed. Name comments that
   restate the code, are wrong, or are missing on a public interface.
6. **Man pages**, if any changed. Run `mandoc -Tlint -Wstyle` and
   `igor -D` on each, and report what they find. Check that SYNOPSIS, the option list, and
   the code all agree, and that every example would work.
7. **Excess.** Point out anything a reader does not need: padding,
   repetition, and sections with nothing to say.

End with the single change that would help readers most. Keep the
whole report under 400 words.
