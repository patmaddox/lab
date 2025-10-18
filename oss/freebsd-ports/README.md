# freebsd-ports

Ports I maintain: https://portscout.freebsd.org/pat@patmaddox.com.html

jj aliases:

|-------|-------------------------------------------|
| diffs | all of my patches not descended from main |
| unsub | patches that do not have a PR label       |

Basic workflow:

1. Update the port, based off main@upstream
2. Rebase it into my dev branch
3. Make a PR
4. Rebase it into my main branch

Cleaning kmods for a version update (STABLE / CURRENT):

`for p in $(find /usr/local/poudriere/data/packages/143-default/All/ -name '*kmod*'); do pkg info -F ${p} | awk '$1 == "Origin" { origin=$NF }; $1 == "flavor" { flavor="@"$NF }; END { print origin flavor }'; done | xargs poudriere pkgclean -j 143 -C -y`
