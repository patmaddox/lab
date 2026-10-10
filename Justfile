help:
  just -l

# purge deleted emails from disk
purge:
  #find -E maildir/ -regex ".*,DS?$" -delete
  find maildir -name '*,D' -delete

advance:
  jj b m mail -t 'heads(::@ ~ description(exact:"") | mail)'

fetch:
  jj --quiet git fetch --remote submissions
  jj --quiet rebase -b @ -d 'heads((::@ & immutable()) | claude@submissions)'
  jj --quiet simplify-parents

push:
  jj --quiet git push -b mail --remote tngl
  jj --quiet git push -b mail --remote jails
  jj --quiet git push -b mail --remote github
  jj --quiet git export
