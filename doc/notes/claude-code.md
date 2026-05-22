# Tools for Viewing Claude Code Streaming JSON Output

Claude Code's `-p` (pipe/print) flag runs non-interactively, and
`--output-format stream-json` emits every token, tool call, and turn
as newline-delimited JSON (NDJSON). This output is verbose and hard to
read raw. Here are existing tools and approaches for making it
readable.

## Existing Tools

### format-claude-stream

[format-claude-stream](https://github.com/Khan/format-claude-stream)
is a CLI filter from Khan Academy that converts Claude Code's
streaming JSON into color-coded, human-readable terminal output. It
can process live piped streams or saved JSON files for later review.

### fx

[fx](https://fx.wtf) is a terminal JSON viewer that supports streaming
NDJSON input. It can be used to interactively explore and filter
Claude Code's stream-json output.

## Potential Approaches Not Yet Built

### Phoenix LiveView viewer

The NDJSON format is well-suited to a Phoenix LiveView app — each JSON
line could be parsed and rendered as a discrete component (tool calls,
assistant text, cost info, etc.) updating in real time. The
[claude_code_sdk Elixir
package](https://hexdocs.pm/claude_code_sdk/claude_code_sdk.epub)
could help with integration.

## Skills

Skills are prompt templates that live in `.claude/skills/`. Each skill
is a directory with a `SKILL.md` file and optional supporting files.

Skills are not a tool-definition mechanism. They tell Claude what to
do using the existing built-in tools (Bash, Read, Edit, etc.). The
main value is bundling instructions with scripts so Claude knows when
and how to run them.

### Directory layout

```
.claude/skills/my-skill/
├── SKILL.md
└── scripts/
    └── helper.sh
```

### SKILL.md frontmatter

```yaml
---
name: my-skill
description: What this does
allowed-tools: Bash Read
---
```

`allowed-tools` pre-approves built-in tools so Claude does not prompt
for permission each time the skill runs.

### Referencing scripts

`${CLAUDE_SKILL_DIR}` resolves to the skill's directory, so paths
work regardless of the current working directory:

```markdown
To check status, run:
${CLAUDE_SKILL_DIR}/scripts/helper.sh
```

A skill can also call repo-level scripts directly:

```markdown
To check status, run:
./libexec/helper.sh
```

Both end up as Bash calls. The difference is just the path.

### Dynamic context injection

The `!` prefix runs a command at skill load time and substitutes
its output into the prompt before Claude sees it:

```markdown
Current workspaces:
!`./libexec/list-workspaces.sh`

Based on the above, suggest which workspace to use.
```

## References

- [format-claude-stream (GitHub)](https://github.com/Khan/format-claude-stream)
- [fx - terminal JSON viewer](https://fx.wtf)
- [How to Extract Text from Claude Code JSON Stream Output](https://www.ytyng.com/en/blog/claude-stream-json-jq)
- [Claude Code headless/programmatic docs](https://code.claude.com/docs/en/headless)
- [claude_code_sdk on HexDocs](https://hexdocs.pm/claude_code_sdk/claude_code_sdk.epub)
- [Streaming Claude Code with AFK Ralph](https://www.aihero.dev/heres-how-to-stream-claude-code-with-afk-ralph)
