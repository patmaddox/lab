#!/bin/sh
set -eu

root="$(jj root)"

# package-dir:file1 file2 ...
packages="
oss/emacs-prescient:prescient.el vertico-prescient.el
"

echo "$packages" | while IFS=':' read -r pkg files; do
	[ -z "$pkg" ] && continue

	name=$(basename "$pkg" | sed 's/^emacs-//')
	srcdir="${root}/${pkg}/default.jj"
	destdir="${root}/dotfiles/emacs/contrib/${name}"

	if [ ! -d "$srcdir" ]; then
		echo "skip: ${pkg} (not cloned)" >&2
		continue
	fi

	rm -rf "$destdir"
	mkdir -p "$destdir"

	tar -C "$srcdir" -cf - ${files} | tar -C "$destdir" -xf -

	echo "updated: ${name}"
done
