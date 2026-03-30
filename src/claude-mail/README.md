# claude-mail

Pipe emails to Claude and collect replies.

## Usage

### Send an email to Claude

```sh
claude-mail-send id:<message-id>
```

Fetches the email by notmuch message ID and sends it to Claude
with a system prompt. Claude writes one or more reply `.eml` files
directly to `/tmp/claude-replies/`.

### Ingest replies into notmuch

```sh
claude-mail-ingest
```

Reads all `.eml` files from `/tmp/claude-replies/`, runs
`notmuch insert` on each, and removes the originals.

## Files

- `bin/claude-mail-send` - Main script: email -> Claude -> reply
- `bin/claude-mail-ingest` - Ingest replies into notmuch
- `lib/mail-reply.prompt` - System prompt for Claude

## Requirements

- [notmuch](https://notmuchmail.org/)
- [Claude Code CLI](https://claude.ai/code)
