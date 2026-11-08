#!/bin/sh
# PostToolUse hook for Bash. After a jj command that writes a commit
# message or changes a commit's diff, remind the agent to check the
# affected messages with the commit-message skill.

set -eu

cmd=$(jq -r '.tool_input.command // empty')

pattern='(^|[[:space:];&|(])jj[[:space:]]+(commit|ci|describe|desc|squash|split|absorb|diffedit|resolve)([[:space:]]|$)'
printf '%s\n' "$cmd" | grep -Eq "$pattern" || exit 0

# Commits the last operation rewrote, less empty ones.
commits=$(jj --ignore-working-copy op show --no-graph 2>/dev/null |
    awk '/^Changed commits:/ { on = 1; next }
         /^$/ { on = 0 }
         on && /^\+ / && !/\(empty\)/ { sub(/^\+ /, "  "); print }') || true

msg="A jj command just wrote a commit message or changed a commit's diff. Follow the commit-message skill for each affected commit whose message or diff changed, unless you just applied that skill's output."
if [ -n "$commits" ]; then
    msg="$msg
Commits rewritten by the last operation:
$commits"
fi

jq -n --arg msg "$msg" '{
    hookSpecificOutput: {
        hookEventName: "PostToolUse",
        additionalContext: $msg
    }
}'
