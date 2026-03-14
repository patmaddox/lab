#!/bin/sh
# Run claude inside a jj lock with working copy protocol.
#
# Acquires .jj/claude.lock, ensures @ is an empty commit at the
# tip of wip::, runs claude, and leaves @ clean afterwards.
#
# Usage: claude-run.sh [claude args...]

set -eu

root=$(jj root)
lock="$root/.jj/claude.lock"

# Ensure @ is an empty commit at the youngest descendant of wip::
setup_workcopy() {
    tip=$(jj log --no-graph -r 'latest(wip::)' --limit 1 -T 'change_id')
    short=$(printf '%.8s' "$tip")

    if jj diff --git -r "$short" --summary | grep -q .; then
        # Tip has changes, create a new empty commit on top
        jj new "$short"
    else
        # Tip is empty, edit it
        jj edit "$short"
    fi
}

# After claude exits, ensure @ is an empty commit at the tip
cleanup_workcopy() {
    if jj diff --git --summary | grep -q .; then
        jj new
    fi
}

setup_workcopy

lockf -k "$lock" ./dotfiles/emacs/lisp/claude-code/claude-jail.sh "$@"

cleanup_workcopy
