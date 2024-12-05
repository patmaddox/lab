# Manage `/dev/video` and `webcamd`
mod webcam 'src/just-mods/webcam'

help:
  @just -l

# rebase given commits onto trunk
rebase +commits:
  echo {{commits}} | sed -e 's/ / -b /g' -e 's/^/-b /' | xargs jj rebase -d trunk
