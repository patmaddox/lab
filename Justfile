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

# review a [REVIEW] or [SIGNOFF] commit (earliest by default, or specify a change id)
review *id:
  #!/bin/sh
  if [ -n "{{id}}" ]; then
    id="{{id}}"
  else
    id=$(jj log --no-graph --reversed --limit 1 -r 'reviews() | needs_signoff()' -T 'change_id')
  fi
  if [ -z "$id" ]; then echo "No reviewable commits found"; exit 1; fi
  if jj log --no-graph -r "$id & needs_signoff()" -T 'change_id' | grep -q .; then
    JJ_EDITOR="./libexec/just/signoff-edit.sh" jj describe -r "$id"
  else
    JJ_EDITOR="./libexec/just/emacs-diff-edit.sh" jj describe -r "$id"
  fi

# sink reviewed commits toward trunk, promoting when ready
promote *revset:
  ./libexec/just/promote.sh "{{revset}}"

cleanup:
  find . -name '*~' -delete
  find . -type d -empty -delete

# format modified files
@fmt:
  ./libexec/just/fmt.sh

# select a project and start a dev session
dev:
  ./libexec/just/dev.sh

# set author to me on commits matching revset
jj-authorme revset:
  jj metaedit --update-author -r '{{revset}}'

# purge deleted tag emails from notmuch database
claude-mail-purge:
  NOTMUCH_CONFIG=$(realpath .notmuch-config) notmuch search --output=files 'tag:deleted' | xargs rm

