# Checking docs with tools

Run the checks that apply to the files you changed, before the
fresh-eyes review. These are the tools the FreeBSD Documentation
Project uses or recommends, and the claude-repo-docs package installs
all of them. Their findings are candidates, not verdicts. Read each
one, fix what is real, and leave alone what is not, such as a
technical term flagged as a misspelling. If a tool is missing, say so
in your report rather than skipping it silently.

Check only the files you changed. Don't fix findings in text you did
not touch, but mention any serious ones in your report.

## Man pages

FreeBSD's CONTRIBUTING.md says: "Changes should pass `mandoc -Tlint`
and igor." The FreeBSD documentation primer adds a spelling check and
a reading of the rendered page.

1. **mandoc.** Run this:

       mandoc -Tlint -Wstyle page.1

   It reports parse errors, sentences that do not start on a new line,
   SEE ALSO entries out of order, references to pages it cannot find,
   and more. It exits 2 when it finds warnings, which is not a crash.

   - In FreeBSD src, also run `mandoc -Tlint page.1` without
     `-Wstyle`, which adds the base system's own conventions.
   - `-Wstyle` looks up `Xr` targets in the system's manuals and in
     the man path. If the repo keeps its pages in section directories
     such as `man1/` and `man8/`, add `-m <dir>` so that references to
     the repo's own pages resolve. Otherwise, expect "referenced manual
     not found" for them, and check those references by hand.

2. **igor.** Run this:

       igor -D page.1

   It reports repeated words, misspellings, contractions, sentences
   not on a new line, duplicate SEE ALSO entries, and whitespace
   errors, one per line as `file:line:check:text`. It exits 0 even
   when it finds problems, so read its output. `-D` skips the check
   that `.Dd` is today's date, because the date is your decision (see
   man-pages.md).

3. **Spelling.** Check the rendered text, so macro names are not
   reported as misspellings:

       mandoc -Tutf8 page.1 | col -b | aspell list --lang=en | sort -u

   It prints each word it doesn't know. Expect names, commands, and
   terms, and look only for real misspellings.

4. **Prose.** Run Vale on the rendered text, with the configs
   described under Other docs:

       mandoc -Tutf8 page.1 | col -b | vale --config <skill dir>/vale.ini --ext=.txt

5. **Links between pages**, in a tree built with bsd.man.mk: run
   `make manlint`. It runs mandoc and checks that each `MLINKS` name
   appears as an `.Nm` in its page. In other build systems, check by
   hand that each alias the build installs is named in the page.

6. **Read it.** Run `mandoc -a page.1` or `man ./page.1`, and read the
   page as a reader will see it.

## Other docs and code comments

1. **Vale** checks prose in Markdown, org, AsciiDoc, reStructuredText,
   plain text, and the comments in source files.

   - Run the config that ships with this skill, in the directory that
     holds its SKILL.md. It checks for repeated words and for the
     sentence faults in `style.md` that a pattern can find, and leaves
     spelling to codespell:

         vale --config <skill dir>/vale.ini <files>

     Its Plain style also flags quoted examples and some legitimate
     uses, such as "what the code actually does". Fix the sentences
     that `style.md` would rewrite, and leave the rest.
   - If the repo has a `.vale.ini`, also run `vale <files>` from the
     repo root, so its rules apply.

   Vale exits 1 when it finds errors. A repo's own config may enable
   spelling, which flags technical terms, so judge each finding.

2. **codespell** finds common misspellings in source and docs, with
   few false positives:

       codespell <files>

   It exits non-zero when it finds any. Run it on source files whose
   comments you changed, and on Markdown or org docs. Don't run it on
   mdoc source, because it misreads macro names such as `Nd`.

3. **Links.** Check that each relative link and path you wrote
   resolves to a file in the repo.

4. **Rendering.** If the repo builds its docs with a tool such as Hugo,
   Sphinx, mdBook, or Asciidoctor, and building is quick and needs no
   network, build them and check that your pages render without new
   warnings.
