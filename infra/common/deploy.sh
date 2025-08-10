#!/bin/sh
set -eu

# Read target host from build.ninja in current directory
target_host=$(grep "host_name = " build.ninja | cut -d' ' -f3)
current_host=$(hostname -s)

# Determine how to run ansible-playbook
if [ "$current_host" = "$target_host" ]; then
    # Local deployment
    ansible-playbook -i localhost, -c local ../../common/deploy.yml
else
    # Remote deployment
    ansible-playbook -i "$target_host", ../../common/deploy.yml
fi
