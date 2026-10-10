help:
  just -l

# purge deleted emails from disk
purge:
  #find -E maildir/ -regex ".*,DS?$" -delete
  find maildir -name '*,D' -delete
