#!/bin/sh
BASE=$(dirname $(realpath $0))/..
. $BASE/lib/libhelper.sh
require_lib "hello"

hello
