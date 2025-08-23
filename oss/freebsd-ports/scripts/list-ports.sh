#!/bin/sh
set -eu

main() {
    (flavored_ports; unflavored_ports) | unique_ports | format_ports
}

flavored_ports() {
    pkg query -e '%a = 0' '%o %At %Av' | awk '$2 == "flavor" && $3 != "default" { printf("%s %s\n", $1, $3) }'
}

unflavored_ports() {
    pkg query -e '%a = 0' '%o'
}

unique_ports() {
    sort -s -u -k 1,1
}

format_ports() {
    tr ' ' '@'
}

main
