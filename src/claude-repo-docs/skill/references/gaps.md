# Finding gaps and drift

A gap is something a reader needs that the docs do not give them.
Drift is something the docs say that the code no longer does. Find
both by comparing three things: the code, the docs, and the readers'
needs.

## 1. Inventory the docs

List the docs that cover the target paths: READMEs, docs/ trees, man
pages, docstrings, and help text. For each, note its readers, the
mode of each section, and when it last changed, from the version
control log.

## 2. Inventory the code's surface

List what a reader would need documented:

- What the project or directory is for, and how it fits the repo.
- How to build, test, install, and run it. Take these from the
  Makefile, Justfile, package scripts, redo or ninja files, CI config,
  or Dockerfile.
- Public interfaces: commands and their options, exported functions
  and types, endpoints, file formats.
- Configuration: files, keys, environment variables, defaults.
- Requirements: platforms, dependencies, services.
- Behavior a user will trip over: errors, limits, side effects,
  destructive operations.

## 3. Compare

For each item, decide whether it is:

- **Covered and true.** Leave it.
- **Drifted.** The docs name a command, flag, path, or default the
  code no longer has, or describe behavior it no longer has. Correct
  it. This comes first, since wrong docs are worse than missing ones.
- **Missing.** No doc covers it. Fill it if readers need it.
- **Duplicated.** Two docs cover it, and they disagree or will. Keep
  one, and link to it from the other. Say which you kept and why.
- **Dead.** Docs for code that no longer exists. Delete them, or
  propose deletion if the request did not cover it.
- **Excess.** Docs that tell a skilled operator what they already
  know, or take a paragraph for what a line would say. Cut or tighten
  them.

Also check:

- Links and paths inside the repo resolve.
- Every directory a reader will land in has a README, or its parent
  README says what it holds.
- Generated indexes and tables of contents match what they index.

## 4. Choose what to fill

Fill gaps in this order, and stop when the request is served:

1. Drift that would mislead a reader.
2. Missing basics: what it is, how to build or install it, how to run
   it.
3. Missing reference for public interfaces and configuration.
4. Missing explanation of decisions a reader would question.
5. Tutorials, only if asked.

Correct drift, and cut dead and excess text, throughout what the
request covers, whether or not you fill anything. Minimum viable docs
beat complete docs that go stale. Report the gaps you left alone.
