help:
  just -l

sync: fetch commit-mail advance push

# purge deleted emails from disk
purge:
  #find -E maildir/ -regex ".*,DS?$" -delete
  find maildir -name '*,D' -delete

advance:
  jj b m mail -t 'heads(::@ ~ description(exact:"") | mail)'

fetch:
  jj --quiet git fetch --remote submissions
  jj --quiet duplicate -B @ '::claude@submissions ~ ::@'
  jj --quiet abandon 'empty() & mutable() & ::@ ~ mine()'

push:
  jj --quiet git push --tracked --remote tngl
  jj --quiet git push --tracked --remote jails
  jj --quiet git push --tracked --remote github
  jj --quiet git export

summary:
  jj log -s -r '::@ ~::mail'

reauthor *revset:
  jj metaedit --update-author {{revset}}

# commit each mail file added in @ on its own, named for its subject
commit-mail $prefix="msg: ":
  #!/bin/sh
  set -eu
  for f in $(jj st maildir | awk '$1 == "A" { print $2 }'); do
    subject="$(awk '/^$/ { exit } /^[ \t]/ { printf "%s", $0; next } { printf "\n%s", $0 }' "${f}" |
      sed -n 's/^[Ss]ubject: *//p')"
    jj --quiet commit -m "${prefix}${subject:-(no subject)}" "root-file:\"${f}\""
  done
