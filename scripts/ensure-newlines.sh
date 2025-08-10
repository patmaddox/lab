#!/bin/sh
set -eu

# Read file paths from stdin and ensure each file ends with a newline
while IFS= read -r file; do
    # Skip if file doesn't exist or is not a regular file
    if [ ! -f "$file" ]; then
        continue
    fi
    
    # Check if file is empty
    if [ ! -s "$file" ]; then
        continue
    fi
    
    # Check if file ends with newline by reading last character
    if [ "$(tail -c 1 "$file" | wc -l)" -eq 0 ]; then
        echo "Adding newline to: $file"
        echo >> "$file"
    fi
done
