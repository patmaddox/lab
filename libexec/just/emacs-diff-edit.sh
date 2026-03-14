#!/bin/sh
# Open a file in emacsclient in diff-mode, blocking until C-x #
emacsclient -ca '' --eval "(progn (find-file \"$1\") (diff-mode))" > /dev/null
