# Manual pages

Write and revise Unix manual pages in mdoc(7), in FreeBSD style unless
the repo's existing pages follow another. The installed pages mdoc(7),
style.mdoc(5), roff(7), and mandoc(1) are the authorities, and
/usr/share/examples/mdoc/ holds templates. Read them on the host when
a question is not settled here.

A man page is reference. It is terse and complete, and it is
consulted rather than read through. Its EXAMPLES section is a small
how-to. Tutorials and long explanations belong elsewhere, linked from
SEE ALSO.

## Before writing

- Look at the repo's other man pages. Match their header comment,
  license, date style, and section choices.
- Read two or three installed pages for tools like the one you are
  documenting. Choose them by the same manual section and the same
  kind of tool: a network daemon, a file format, a driver, or a
  command with subcommands. Find them with `apropos -s <section>
  <keyword>`, through the SEE ALSO of a page you already know, or
  through the pages for the tools your subject wraps or works with.
  Learn from them which sections such pages use, how they word
  recurring things, and which pages to refer to in SEE ALSO. Don't
  copy their length or their structure. A page should be as long as
  its own subject needs.
- If you have no related page to go on, the FreeBSD documentation
  primer recommends cp(1), crontab(5), vt(4), and gpart(8) as
  well-written pages, and the templates in /usr/share/examples/mdoc/
  show the skeleton of each manual section. A minimal system, such as
  a jail, may lack some of these. Read them at https://man.freebsd.org
  if so.
- Learn the interface from the code: every option, argument,
  environment variable, file, exit status, and message. The SYNOPSIS
  and option list must match what the parser accepts, and nothing
  else.
- Find how the repo installs pages. In a FreeBSD Makefile this is
  `MAN=` and `MLINKS=` (bsd.man.mk). A ports or packaging plist must
  list the page as well. Add the new page there, or report that it
  is missing.

## Which language

Use mdoc(7) for every new page. It is semantic, mandoc and groff
both render it, and FreeBSD, OpenBSD, and NetBSD require it. Use
man(7) only to revise a page already written in it, or in a project
that has standardized on it, such as the Linux man-pages project. If
a target platform lacks mdoc support, ship the output of
`mandoc -Tman` and keep the mdoc as the source. Generators such as
help2man, scdoc, ronn, and pandoc produce presentational man(7) with
no semantic markup. Don't introduce one unless the repo already uses
it.

## Sections and their order

Every page starts with the prologue `.Dd`, `.Dt`, `.Os`, in that order,
then NAME, SYNOPSIS where it applies, and DESCRIPTION. Every other
section is optional. Include a section only when it tells the reader
something useful that the rest of the page does not. A short page
with five sections is better than a long one padded to twenty.
Never add a section to fill out the list. Signs of padding include:

- BUGS that say there are none;
- AUTHORS or HISTORY that the repo gives no facts for;
- STANDARDS for a tool that implements none;
- ENVIRONMENT or FILES that list nothing the tool actually reads;
- EXAMPLES that only repeat the SYNOPSIS.

The table lists the conventional sections in their order. The middle
column names the manual sections each can apply to, not those that
require it.

| Section | Can apply to | Contents |
|---|---|---|
| NAME | all | `.Nm` names, then one `.Nd` |
| LIBRARY | 2, 3, 9 on FreeBSD | `.Lb` (elsewhere, put `.Lb` first in SYNOPSIS) |
| SYNOPSIS | 1, 2, 3, 4, 6, 8, 9 | Invocation, function prototypes, or config lines |
| DESCRIPTION | all | What it does, then the options |
| CONTEXT, LOCKING | 9 | Calling context, locks held or taken |
| IMPLEMENTATION NOTES | any | Side effects and algorithms worth knowing |
| RETURN VALUES | 2, 3, 9 | `.Rv -std` when it fits |
| ENVIRONMENT | 1, 6, 7, 8 | Each variable read, and its effect |
| FILES | any | Each file used, and how |
| EXIT STATUS | 1, 6, 8 | `.Ex -std` when it fits |
| EXAMPLES | any | Tested invocations, each with a lead-in |
| DIAGNOSTICS | 1, 4, 6, 7, 8, 9 | Messages printed to stderr or the console |
| ERRORS | 2, 3, 4, 9 | errno values, `.Er`, alphabetical |
| SEE ALSO | most | Related pages, then other documents |
| STANDARDS | any | Standards implemented |
| HISTORY | any | Where and when it first appeared |
| AUTHORS | any | Who wrote it |
| CAVEATS | any | Common misuses and misunderstandings |
| BUGS | any | Known bugs and limitations |
| SECURITY CONSIDERATIONS | any | Precautions for operators |
| HARDWARE | 4 | Supported devices (see Section 4 below) |

HARDWARE sits between DESCRIPTION and the later sections in FreeBSD
driver pages. Most pages also have a SEE ALSO, since there is nearly
always a related page worth pointing to.

## Additional sections

The list above is the conventional set, not a closed one. Many
FreeBSD pages add sections of their own. For example, make(1) has
SHELL COMMANDS and SPECIAL TARGETS, zfs(8) has SUBCOMMANDS, and
ifconfig(8) has PARAMETERS. mandoc accepts any section name. It warns
only when the sections it knows are out of their conventional order.

Sections that recur in FreeBSD's own pages:

| Section | Holds | Place it |
|---|---|---|
| OPTIONS, COMMANDS, SUBCOMMANDS, PARAMETERS | An option or command list too long to sit well in DESCRIPTION | Right after DESCRIPTION |
| Topic sections, such as a grammar, file format, or protocol | Parts of a long DESCRIPTION, each large enough to look up on its own | Right after DESCRIPTION, in the order a reader needs them |
| SYSCTL VARIABLES, LOADER TUNABLES | A driver's or subsystem's sysctl(8) variables and loader.conf(5) tunables, each in a tagged list with `Va` | After DESCRIPTION and HARDWARE |
| COMPATIBILITY | Differences from other implementations or from earlier versions | After DIAGNOSTICS, before ERRORS and SEE ALSO |
| NOTES | Remarks that fit no other section | Prefer CAVEATS, BUGS, or IMPLEMENTATION NOTES. mdoc(7) does not define NOTES |

When writing a page:

- Use the standard sections first. Add a section of your own only when
  no standard section fits the content and the content is large
  enough to need its own heading. Otherwise, use an `.Ss` subsection
  within DESCRIPTION.
- Name it in capitals, with the words a reader would look for, such
  as SYSCTL VARIABLES rather than TUNING. Make each name unique on the
  page, so that `Sx` can refer to it.
- Place it where it leaves the standard sections in their order.
  Topic sections almost always follow DESCRIPTION directly.
- Follow the precedent of the repo's other pages, and of related
  system pages. If they use an OPTIONS section, use one too.

When revising a page, keep its additional sections, their names, and
their order, unless the request covers restructuring. A section that
seems out of place may be a deliberate choice. Check the repo's docs
and history, such as a decisions file or commit messages, before you
move or rename one, and report what you found.

## Source conventions

- Start every sentence on a new input line, and end it at the end of
  the line. Formatters find sentence ends only there. If a line ends
  in a period that does not end a sentence, as in an abbreviation,
  append `\&`.
- Keep input lines under about 80 columns. Break long sentences at
  clause boundaries.
- Leave no blank lines, and no trailing whitespace. Use `.Pp` for a
  paragraph break.
- Put a space before punctuation that follows a macro argument:
  `.Xr geom 4 ,` and not `.Xr geom 4,`.
- Use `.Dd` for the date of the last change that affects content, as
  `Month day, year`. Set it to today's date when writing or changing
  the substance of a page, and leave it alone for typo fixes. Follow
  the repo's own rule where it has one. FreeBSD src's CONTRIBUTING.md
  says "Proposed changes to manual pages should not bump the document
  date until merged," so there, leave `.Dd` alone and say in your
  report that it needs a bump on merge. Use `$Mdocdate$` only in an
  OpenBSD tree.
- Write `.Dt` as the name in capitals and the section number, as
  `.Dt LINKCHECK 1`. Give `.Os` no argument.
- Use no roff requests and almost no escapes. `\&`, `\e`, and `\(em`
  cover nearly every need.
- Start a page with the repo's usual comment header. FreeBSD uses a
  copyright line and an SPDX license identifier. Follow the repo's
  license, and don't add one the repo does not use.

## Semantic markup

Mark up what a word is, not how it should look.

| Macro | For |
|---|---|
| `Nm` | The page's own subject. Never for another page's subject |
| `Fl` | A flag: `Fl v` renders as `-v` |
| `Ar` | A placeholder the user replaces: `Ar file` |
| `Cm` | A fixed keyword or subcommand: `Nm git Cm commit` |
| `Ic` | A command typed on its own, such as an interpreter or config keyword |
| `Op` | Optional part of a SYNOPSIS |
| `Pa` | A path |
| `Ev` | An environment variable |
| `Va` | A variable, including sysctl names |
| `Dv` | A defined constant |
| `Er` | An errno value |
| `Xr` | Another page: `Xr mandoc 1` |
| `Sx` | A section of this page |
| `Fn`, `Fa`, `Ft`, `Fo`/`Fc`, `In`, `Vt` | Functions, arguments, types, headers |
| `Lk`, `Mt` | A URL, an email address |
| `Dq`, `Sq` | Quotation, and quotation inside it |
| `Ql`, `Dl`, `Bd -literal` | Literal text, one indented line, a block |
| `Em`, `Sy` | Emphasis, only when no semantic macro fits |

Inside `Ql`, `Dl`, and `Bd -literal`, write the text plainly. Don't
mark up the parts of a literal command or code sample. Where a
sample holds placeholders, use `Bd -unfilled` or `D1` with `Ar`.

## NAME

`.Nd` is one line in lowercase, with no final period. For a command
or function, write an imperative clause, such as
`.Nd check a site for broken links`. For a file format, device, or
overview, write a noun phrase, such as `.Nd mdoc language reference`.
List several names with commas, the `.Dt` name first and the rest in
alphabetical order. Document several commands or functions in one
page only when separate pages would repeat most of their text.

## SYNOPSIS

Show the syntax only, and never explain it there.

- For a utility, write `.Nm` alone, since it repeats the name.
- Group the flags that take no argument into one `.Op Fl` and sort
  them: `.Op Fl acv`.
- Then give each option that takes an argument its own
  `.Op Fl o Ar file`, in alphabetical order.
- Put the operands last. Mark optional ones with `Op`, and repeated
  ones with `...` or a bare `.Ar`.
- Show alternatives with a bare `|` argument. Don't use braces.
- List long options after the short ones, and omit long aliases of
  short options.
- Never write `.Op Ar options` or `[options]`. Name each option.
- For several commands, give each its own `.Nm` line, sorted.
- For functions, order `.In`, `.Vt`, `.Ft`, and `.Fn` as a C header
  would.

## DESCRIPTION

Open by expanding the `.Nd` line in a sentence:

```
The
.Nm
utility checks every link it finds while crawling a site.
```

Describe the default behavior and the operands, then the options:

```
The options are as follows:
.Bl -tag -width Ds
.It Fl a
Check every link, including those to other hosts.
.It Fl o Ar file
Write the report to
.Ar file
instead of standard output.
.El
```

- Sort the options with digits first, then by letter. Put uppercase
  before lowercase for the same letter, whatever the option takes.
- Describe each option in the present tense, starting with a verb:
  "Print", "Write", "Ignore". Give its default and any interaction
  with other options.
- `-width` should match the longest item. Use `Ds` for short flags,
  or `indent` when the longest item is too long to read well.
- Document subcommands in their own tagged list, or in `.Ss`
  subsections, using `Cm` for the subcommand names.

## ENVIRONMENT and FILES

Use a tagged list with one item per variable or path. Say what each
variable changes and its default. Say how each file is used: read,
created, or modified.

```
.Sh ENVIRONMENT
.Bl -tag -width LINKCHECK_AGENT
.It Ev LINKCHECK_AGENT
The HTTP user agent to send.
The default is
.Ql linkcheck/1.0 .
.El
```

## EXIT STATUS, RETURN VALUES, DIAGNOSTICS, and ERRORS

- Use `.Ex -std` for a utility that exits 0 on success and more than
  0 on error. If the utility is close to that, copy the wording of
  `.Ex -std` and change only what differs. Otherwise, list each
  status in a tagged list.
- Use `.Rv -std` for functions that return 0 on success and -1 with
  errno set. Otherwise, describe the return values.
- DIAGNOSTICS lists messages as they print, in `.Bl -diag`, each with
  its cause and remedy. Document only messages a user could act on.
- ERRORS lists errno values with `.It Bq Er EINVAL`, sorted
  alphabetically. Repeat a value that has more than one cause.

## EXAMPLES

Readers often turn to EXAMPLES first, so most commands deserve one.
Up to about three is a good range: a minimal use, a typical real use,
and one that shows non-obvious behavior. Include only those that teach
something the SYNOPSIS does not.
Every example must be an invocation you have checked against the
code, and run where that is safe. Give each a lead-in sentence.

FreeBSD style.mdoc(5) formats them like this:

```
.Sh EXAMPLES
.Bl -tag -width 0n
.It Sy Example 1\&: Check a local site
.Pp
Check every page reachable from the root of a site on localhost:
.Bd -literal -offset 2n
.Ic $ linkcheck http://localhost:8080 http://localhost:8080/
.Ed
.El
```

A short page may instead give each example as a paragraph followed
by `.Dl` or `.Bd -literal -offset indent`. Follow the style of the
repo's other pages. Show the prompt `$` for a user, and `#` for root.

## SEE ALSO

Give one `.Xr` per line, each followed by ` ,` except the last, with
no period at the end. Sort the entries by section, then alphabetically
ignoring case. Don't refer to the page itself. Refer only to pages
that exist on the target system or in the repo. Books, papers, and
RFCs follow, in `.Rs` blocks, and websites go in `.Lk`.

## STANDARDS, HISTORY, and AUTHORS

- STANDARDS names what the subject complies with, using `.St` where it
  has an entry, such as
  "The `.Nm` utility is compliant with the `.St -p1003.1-2008`
  specification." Name extensions to the standard.
- HISTORY says where the subject first appeared, as "The `.Nm` utility
  first appeared in `.Fx 14.0` ." Use only facts from the repo's
  history or its existing docs. If they say nothing, omit HISTORY.
- AUTHORS uses `.An Name Aq Mt address`. Use names that the repo
  already credits, and never invent an author or an address.

## CAVEATS, BUGS, and SECURITY CONSIDERATIONS

- CAVEATS covers ways people misuse the subject, or surprises that are
  intended.
- BUGS lists known defects and limitations, with workarounds. Never
  write "no known bugs."
- SECURITY CONSIDERATIONS says what an operator must guard against.
  Use it for anything that runs as root, handles credentials, or
  trusts input.

## Section 4 and section 9

- A FreeBSD driver page has a SYNOPSIS of `.Cd` kernel config lines,
  then a `.Pp` and the `loader.conf` line that loads the module. Its
  HARDWARE section is copied verbatim into the release hardware
  notes. It opens with "The `.Nm` driver supports the following
  <device class>:" and then a bullet list of devices.
- A section 9 page documents kernel interfaces. It adds CONTEXT or
  LOCKING, RETURN VALUES, and ERRORS as they apply.

## Checking

Run the man page checks in `checks.md`: mandoc, igor, spelling on the
rendered text, Vale, and a read of the rendered page. Then check
every option in SYNOPSIS against the option list and the code. No
tool checks that.

## Common mistakes

- An option in SYNOPSIS but not in DESCRIPTION, or the reverse.
- An option the code does not accept, or one the code accepts that
  the page omits.
- More than one sentence on a line.
- `.Nd` capitalized or ending in a period.
- Options out of order.
- Physical markup (`Em`, `Sy`, `\fB`) where `Fl`, `Ar`, `Pa`, or
  `Ev` fits.
- `Nm` used for a different program.
- Explanation in SYNOPSIS, or prose rationale in an option's entry.
  Move it to DESCRIPTION, CAVEATS, or a linked doc.
- `.Dd` left unchanged after a change to the substance of the page.
- A period after the last SEE ALSO entry.
- A README that repeats the option list. Link it to the man page
  instead.

## Sources

FreeBSD mdoc(7), style.mdoc(5), roff(7), and mandoc(1), and
/usr/share/examples/mdoc/;
https://docs.freebsd.org/en/books/fdp-primer/manual-pages/;
https://man.openbsd.org/mdoc.7; https://mandoc.bsd.lv/mdoc/;
https://manpages.bsd.lv/; https://netbsd.org/developers/manpages.html;
https://man7.org/linux/man-pages/man7/man-pages.7.html.
