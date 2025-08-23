#!/bin/sh
set -eu

jj st | awk '/^[A|M] / {print $2}' | while IFS= read -r file; do
    if [ ! -f "$file" ] || [ ! -s "$file" ]; then
        continue
    fi

    sed -i '' 's/[[:space:]]*$//' "$file"

    if [ "$(tail -c 1 "$file" | wc -l)" -eq 0 ]; then
        echo >> "$file"
    fi
done
