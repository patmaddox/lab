#!/bin/sh
find . -name '*.do' | sed -e 's/\.do$//' | xargs rm -f
find . -type d -empty -delete
