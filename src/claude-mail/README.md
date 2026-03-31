# claude-mail

Pipe emails to Claude and collect replies. When emails request
code changes, Claude works in an isolated git clone and produces
patch series.

## Usage

### Handle a message

```sh
claude-handle-message id:<message-id>
```

Fetches the email by notmuch message ID, clones the repo to a
temporary workspace, and sends the message to Claude with a system
prompt. Claude writes reply `.eml` files and patch series to a
staging directory in the workspace, then ingests them into notmuch
automatically.

## Files

- `bin/claude-handle-message` - Main script: email -> workspace -> Claude -> reply/patches
- `bin/claude-mail-ingest` - Ingest replies into notmuch
- `lib/handle-message.prompt` - System prompt for Claude

## Requirements

- [notmuch](https://notmuchmail.org/)
- [Claude Code CLI](https://claude.ai/code)
- git
