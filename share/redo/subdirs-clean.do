# symlink this to clean.do in any dir that should build subdirs
files=$(ls */clean.do 2>/dev/null || true)
if [ -n "${files}" ]; then redo ${files%.do}; fi
