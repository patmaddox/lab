#!/bin/sh
# Sink promotable commits as far down the stack as they can go.
#
# A promotable commit has no bracketed tags in the subject, or is
# tagged [BLOCKED] or [SIGNOFF] from a previous run.
#
# Stops when:
#   - A rebase causes a conflict → undo, mark [BLOCKED]
#   - Parent is trunk and commit lacks Signed-off-by: → mark [SIGNOFF]
#   - Parent is trunk, has Signed-off-by: → advance trunk bookmark
#
# Dev is just a marker commit — candidates sink right past it.

set -eu

has_conflict() {
    jj log --no-graph -r "$1" \
        -T 'if(conflict, "yes", "")' | grep -q 'yes'
}

parent_of() {
    jj log --no-graph -r "$1-" -T 'change_id'
}

subject_of() {
    jj log --no-graph -r "$1" -T 'description.first_line()'
}

is_trunk() {
    jj log --no-graph -r "$1 & trunk" -T 'change_id' 2>/dev/null | grep -q .
}

has_signoff() {
    jj log --no-graph -r "$1" -T 'description' | grep -q '^Signed-off-by: Pat Maddox <pat@patmaddox.com>$'
}

# Add a tag to the subject if not already present
add_tag() {
    id="$1"
    tag="$2"
    subject=$(subject_of "$id")
    case "$subject" in
        "$tag"*) return ;;
    esac
    body=$(jj log --no-graph -r "$id" -T 'description' | tail -n +2)
    if [ -n "$(printf '%s' "$body" | tr -d '[:space:]')" ]; then
        jj describe -r "$id" -m "$tag $subject
$body" > /dev/null 2>&1
    else
        jj describe -r "$id" -m "$tag $subject" > /dev/null 2>&1
    fi
}

# Remove all promotion tags from the subject
remove_tags() {
    id="$1"
    subject=$(subject_of "$id")
    new_subject=$(printf '%s' "$subject" | sed 's/\[BLOCKED\] *//g; s/\[SIGNOFF\] *//g')
    if [ "$new_subject" = "$subject" ]; then
        return
    fi
    body=$(jj log --no-graph -r "$id" -T 'description' | tail -n +2)
    if [ -n "$(printf '%s' "$body" | tr -d '[:space:]')" ]; then
        jj describe -r "$id" -m "$new_subject
$body" > /dev/null 2>&1
    else
        jj describe -r "$id" -m "$new_subject" > /dev/null 2>&1
    fi
}

REPORT_FMT='"  " ++ change_id.shortest(8) ++ " " ++ description.first_line() ++ "\n"'

# Format a change ID with jj's shortest highlighting
fmt_id() {
    jj log --color=always --no-graph -r "$1" -T 'change_id.shortest(8)'
}

report_group() {
    label="$1"
    revset="$2"
    printf "$label:"
    ids=$(jj log --no-graph -r "$revset" -T 'change_id ++ "\n"' 2>/dev/null || true)
    if [ -z "$ids" ]; then
        printf ' none\n'
    else
        printf '\n'
        jj log --color=always --no-graph -r "$revset" -T "$REPORT_FMT" 2>/dev/null
    fi
}

promoted=""
blocked_ids=""

if [ -n "${1:-}" ]; then
    revset="promotable() & ($1)"
else
    revset="promotable()"
fi

for id in $(jj log --no-graph -r "$revset" -T 'change_id ++ "\n"' 2>/dev/null); do
    short=$(printf '%.8s' "$id")
    subject=$(subject_of "$short")

    while true; do
        parent=$(parent_of "$short")
        parent_short=$(printf '%.8s' "$parent")

        if is_trunk "$parent_short"; then
            if ! has_signoff "$short"; then
                add_tag "$short" "[SIGNOFF]"
                break
            fi
            # Strip tags before advancing trunk (commit becomes
            # immutable once it is the trunk tip)
            remove_tags "$short"
            jj bookmark set trunk -r "$short" 2>/dev/null
            if has_conflict "$short"; then
                jj undo 2>/dev/null
                add_tag "$short" "[BLOCKED]"
                blocked_ids="$blocked_ids $short"
                break
            fi
            promoted="$promoted $short"
            break
        fi

        # Sink one level
        jj rebase -r "$short" -B "$parent_short" 2>/dev/null
        if has_conflict "$short" || has_conflict "$parent_short"; then
            jj undo 2>/dev/null
            add_tag "$short" "[BLOCKED]"
            blocked_ids="$blocked_ids $short"
            break
        fi

        remove_tags "$short"
    done
done

# Report
printf 'Promoted:'
if [ -z "$promoted" ]; then
    printf ' none\n'
else
    printf '\n'
    for id in $promoted; do
        printf '  '
        fmt_id "$id"
        printf ' %s\n' "$(subject_of "$id")"
    done
fi

report_group '\nNeeds sign-off' 'needs_signoff()'
report_group '\nBlocked' 'blocked()'
