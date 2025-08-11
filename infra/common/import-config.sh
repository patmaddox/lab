#!/bin/sh
set -eu

main() {
    # Default to dist/dist.mtree if no argument provided
    MTREE="${1:-dist/dist.mtree}"
    
    # Read target host from build.ninja in current directory
    target_host=$(grep "host_name = " build.ninja | cut -d' ' -f3)
    current_host=$(hostname -s)
    
    # Validate mtree file exists
    if [ ! -f "$MTREE" ]; then
        echo "Error: mtree file not found: $MTREE" >&2
        exit 1
    fi
    
    # Get absolute path and directory
    mtree_path=$(realpath "$MTREE")
    dist_dir=$(dirname "$mtree_path")
    
    if [ "$current_host" = "$target_host" ]; then
        # Local: tar from local root to local dist
        echo "Importing config from local system..."
        doas tar -C / -c @"$mtree_path" | tar -C "$dist_dir" -x
    else
        # Remote: tar from remote root to local dist
        echo "Importing config from remote host: $target_host..."
        
        # Copy mtree to remote temporarily
        mtree_basename=$(basename "$mtree_path")
        scp "$mtree_path" "$target_host:/tmp/$mtree_basename"
        
        # Run tar on remote, extract locally
        ssh "$target_host" "doas tar -C / -c @/tmp/$mtree_basename" | tar -C "$dist_dir" -x
        
        # Clean up remote temp file
        ssh "$target_host" "rm /tmp/$mtree_basename"
    fi
    
    echo "Config import complete."
}

main "$@"