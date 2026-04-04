# Variadic parameters and positional arguments
#
# Just supports variadic parameters, but it breaks down when they have
# whitespace in them. `set positional-arguments` exposes ${@} so that
# the script can iterate over them.

set positional-arguments

demo:
  just -f {{justfile()}} bad-hello edgar "fiona boo"
  just -f {{justfile()}} good-hello edgar "fiona boo"

bad-hello +friends:
  for f in {{friends}}; do echo "hello ${f}"; done

good-hello +friends:
  for f in "${@}"; do echo "hello ${f}"; done
