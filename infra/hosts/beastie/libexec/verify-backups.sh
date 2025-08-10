#!/bin/sh
set -eu

echo "beastie => andre"
zelta match zroot/safe andre-backup:hdd/crypt/snaps/safe/beastie--zroot--safe

echo "andre => rsync.net"
zelta match andre-backup:hdd/crypt/snaps/safe/beastie--zroot--safe zsync-root:zsync/snaps/andre--crypt--snaps--safe/beastie--zroot--safe

echo "beastie => rsync.net (transitive)"
zelta match zroot/safe zsync-root:zsync/snaps/andre--crypt--snaps--safe/beastie--zroot--safe
