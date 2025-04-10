# freebsd-ports

Cleaning kmods for a version update (STABLE / CURRENT):

`for p in $(find /usr/local/poudriere/data/packages/143-default/All/ -name '*kmod*'); do pkg info -F ${p} | awk '$1 == "Origin" { origin=$NF }; $1 == "flavor" { flavor="@"$NF }; END { print origin flavor }'; done | xargs poudriere pkgclean -j 143 -C -y`
