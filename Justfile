# Manage `/dev/video` and `webcamd`
mod webcam 'src/just-mods/webcam'

help:
  @just -l

# fetch trunk from gerrit, rebase dev onto trunk
git-rebase:
  jj git fetch --remote gerrit -b trunk
  jj b s trunk -r trunk@gerrit
  jj rebase -b dev -d trunk --skip-emptied
  jj simplify-parents -r dev

git-push:
  jj git push -b dev --remote srht
  jj git push -b trunk --remote srht
  jj git push -b trunk --remote github

# rebase given commits onto trunk
rebase-n +commits:
  echo {{commits}} | sed -e 's/ / -b /g' -e 's/^/-b /' | xargs jj rebase -d trunk

# clone all repositories
clone:
  for d in src/freebsd-ports src/freebsd-src src/jj src/please; do just -f ${d}/Justfile clone; done

cleanup:
  find . -name '*~' -delete
  find . -type d -empty -delete

# format modified files
@fmt:
  ./libexec/just/fmt.sh

# select a project and start a dev session
dev:
  ./libexec/just/dev.sh
