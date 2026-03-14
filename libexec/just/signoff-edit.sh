#!/bin/sh
# Insert a commented-out Signed-off-by line before the JJ marker comments,
# then open in emacsclient for editing.
#
# jj describe writes a temp file with the commit message followed by
# comment lines (starting with "JJ:"). We insert the signoff template
# just before those comments.

file="$1"
signoff="Signed-off-by: Pat Maddox <pat@patmaddox.com>"

# Check if signoff already present (uncommented)
if grep -Fxq "$signoff" "$file"; then
    exec emacsclient -ca '' "$file"
fi

# Insert commented signoff before the first JJ: line
tmpfile=$(mktemp)
inserted=0
while IFS= read -r line; do
    case "$line" in
        "JJ: "*)
            if [ "$inserted" = 0 ]; then
                printf 'JJ: %s\n\n' "$signoff"
                inserted=1
            fi
            ;;
    esac
    printf '%s\n' "$line"
done < "$file" > "$tmpfile"

# If no JJ: lines found, append at end
if [ "$inserted" = 0 ]; then
    printf '\nJJ: %s\n\n' "$signoff" >> "$tmpfile"
fi

cp "$tmpfile" "$file"
rm "$tmpfile"

exec emacsclient -ca '' "$file"
