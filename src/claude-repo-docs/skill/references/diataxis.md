# Diátaxis, applied per section

Diátaxis (https://diataxis.fr) sorts documentation by the reader's
need. Use it as a lens on each section and paragraph, not as a
template for pages or directories. Its author says to work "a
paragraph or a sentence" at a time, and not to "create empty
structures for tutorials/howto guides/reference/explanation with
nothing in them."

## The compass

Ask two questions of any passage:

1. Does it inform **action** (what to do) or **cognition** (what to
   know)?
2. Does it serve **study** (acquiring skill) or **work** (applying
   it)?

| | Study | Work |
|---|---|---|
| Action | Tutorial | How-to guide |
| Cognition | Explanation | Reference |

The tutorial and how-to split is study against work, not beginner
against advanced. A how-to can cover a basic task.

## What each mode needs

**Tutorial.** A lesson the reader follows to gain skill. Every step
works as written and shows a visible result. It takes one path, with
no choices or branches, and explains only in a clause, linking out
for more. Most small repos need none. Don't write one unless asked or
the project is for newcomers.

**How-to guide.** Steps toward a goal the reader already has, such as
"Deploy to staging." The title names the goal. It states
prerequisites first, then numbered steps with real commands. It
leaves out options the goal does not need, and links to reference for
the rest.

**Reference.** Facts to look up: commands, options, configuration
keys, environment variables, file formats, interfaces. It is complete
and consistent, ordered for scanning, and neutral. It gives examples
but no instructions or opinions. Where the repo keeps reference
elsewhere, such as man pages, docstrings, or generated API docs, link
to it instead of copying it.

**Explanation.** Context, design, reasons, tradeoffs, history. It
answers "why" and "how does this fit together." It may hold opinions
and alternatives, but no step-by-step procedures.

## Per-section judgment

Classify each section with the compass. A page may hold sections of
different modes. A README commonly has an explanation lead, a how-to
for building or installing, and a reference table. That is fine when
each section is clearly headed and serves one need.

Flag blur, not mixing. Change something only when off-mode content
interrupts what the section is for: more than about two sentences of
it, or any list, table, or run of steps.

| Fix it | Leave it |
|---|---|
| A how-to stops between steps for a paragraph of "why" | A one-clause reason in a step, ideally with a link |
| A how-to lists every option and variant ("you can also...") | A prerequisites line, or a short orienting lead |
| A tutorial offers choices, or explains beyond a clause | A short example inside reference |
| Reference holds instructions, "we recommend", or rationale | Several modes on one page, each in its own headed section |
| Explanation holds numbered steps or full option lists | Pages outside the four modes: index, changelog, glossary, FAQ, decision records |
| A title promises one mode and the body delivers another | A short section in a small README that would be silly to split |
| Steps name actions but never show the commands | |

When something needs fixing, prefer the smallest move that serves the
reader:

1. Retitle the section to say what it is for.
2. Split the section in two under clear headings.
3. Move the passage to the section, or page, of its mode, and link to
   it.
4. Only then consider a new page.

Splitting into separate pages costs the reader a jump each time.
Split a page only when a section has grown large enough to serve
readers on its own.
