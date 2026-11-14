# claude-revise-prose

A FreeBSD package that installs a Claude Code skill and an agent.
The `revise-prose` skill decides whether an idea belongs in a commit
message, the docs, or a comment, so that each idea is written once.
The `prose-editor` agent applies the skill to a series of commits.

## Install

The package installs them as a managed skill and agent, under
`/usr/local/etc/claude-code/.claude`. Claude Code reads them only
from `/etc/claude-code`, so that path must link to
`/usr/local/etc/claude-code`. yolo's coding-agent jails have the
link already. On another host, make it first:

    doas ln -s ../usr/local/etc/claude-code /etc/claude-code

Then build and install the package:

    just install

## Use

Claude loads the skill when it writes a commit message, docs, or
comments that explain why or how. To reconcile the messages, docs,
and comments of a series of unpublished commits, run:

    /revise-prose origin/trunk..HEAD

The skill hands the range to the prose-editor agent. The agent
rewrites the commits in place and has a fresh subagent review them.
It repeats until the review finds nothing, for three rounds at most,
then reports what moved in each commit. Asking Claude to run the
agent on a range does the same. The agent's description also invites
Claude to hand it a finished branch unasked, and yolo's coding-agent
jails tell Claude to.

## Design

The skill sits between two others. The commit-message skill writes
messages, and the repo-docs skill writes docs and comments.
revise-prose places each idea where its reader looks, and ranks no
home above another. A message describes the change against the tree
before it, for a reviewer or for someone tracing a line with blame.
Docs describe the tree as it stands, for anyone who uses or maintains
it. Comments serve whoever edits the code beside them. Each has a
cost. A message costs other readers nothing, but users never see it
and it cannot be corrected. Readers find docs and comments without
digging, but every later commit must keep them true. The skill
weighs who needs an idea against those costs.

Each of the other two skills carries a short form of the rule, so the
rule applies where revise-prose is not installed or not loaded. This
skill holds the full rule.

prose-editor is an agent rather than a skill because reconciling a
series is a loop: rewrite, review, and rewrite again until nothing
moves. Its own context keeps the rebases and diffs out of the main
session, and its reviewer reads the prose with no stake in how it was
written.

## Layout

- `skill/SKILL.md` is the skill.
- `agent/prose-editor.md` is the agent. It preloads revise-prose,
  commit-message, and repo-docs. commit-message comes from
  yolo-coding-agent and repo-docs from claude-repo-docs. The agent
  works without either, with less guidance.
- `claude-revise-prose.pkg.do` builds the package with redo.

To try a change without a package, copy `skill/` to a repo's
`.claude/skills/revise-prose`, and `agent/prose-editor.md` to its
`.claude/agents`.
