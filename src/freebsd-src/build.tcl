# call the command runner `tusk`?
source main.tcl

command bootstrap "Build from scratch" {tree} {
    exec ./scripts/build.sh bootstrap $tree >@ stdout
}

command build "Fast build" {tree} {
    exec ./scripts/build.sh build $tree >@ stdout
}

command clean "Clean the build" {tree} {
    exec ./scripts/build.sh clean $tree >@ stdout
}

command release "Build release .txz files" {tree} {
    exec ./scripts/build.sh release $tree >@ stdout
}

command clean-release "Clean release .txz files" {tree} {
    exec ./scripts/build.sh clean-release $tree >@ stdout
}

main $argc $argv
