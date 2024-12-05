: ${BASE:?}
LIB=$BASE/lib

require_lib() {
    . $LIB/lib${1}.sh
}
