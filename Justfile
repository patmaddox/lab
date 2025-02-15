# Manage `/dev/video` and `webcamd`
mod webcam 'src/just-mods/webcam'

help:
  @just -l

# rebase given commits onto trunk
rebase +commits:
  echo {{commits}} | sed -e 's/ / -b /g' -e 's/^/-b /' | xargs jj rebase -d trunk

# clone all repositories
clone:
  for d in src/freebsd-ports src/freebsd-src src/jj src/please; do just -f ${d}/Justfile clone; done

cleanup:
  find . -name '*~' -delete
  find . -type d -empty -delete
