help:
  just -l

# purge deleted emails from disk
purge:
  #find -E maildir/ -regex ".*,DS?$" -delete
  find maildir -name '*,D' -delete

advance:
  jj b m mail -t 'heads(::@ & mutable() ~ description(exact:"") | mail)'

fetch:
  jj git fetch --remote submissions
  jj rebase -b @ -d mail -d claude@submissions
  jj simplify-parents
