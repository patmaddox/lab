#!/bin/sh
exec doas jexec -l -d "$(pwd)" -U "$(whoami)" claude /home/patmaddox/.npm-global/bin/claude "$@"
