#!/bin/sh
set -eu
set -o pipefail

: ${GIT_MAIN}
: ${GIT_TMP}
KERNCONF=${KERNCONF:-GENERIC}
export KERNCONF

main() {
    parse_args "${@}"
    ensure_not_dirty
    reset_worktree

    _make obj
    OBJDIR=$(cmd::objdir)
    cmd::${CMD}
}

# FreeBSD build scripts rely on .git being present, but jj worktrees
# do not have it. Check out the jj workspace to a temporary repo so
# build scripts correctly identify the git revision.
#
# I am not proud of these gymastics.
#
# Create a temp tag point to jj @-, which is the actual latest commit,
# because of how jj uses detached head. Fetch and reset the working
# tree to @-. Delete the tag so that it doesn't mess with jj.
reset_worktree() {
    # ls-files looks in the jj repo. Everything else should be run in
    # a git repo for the worktree.
    if [ "${CMD}" = "ls-files" ]; then
	return 0
    fi

    local branchname githead

    branchname=$(jj -R ${SRC_ROOT} log -r '::@ & bookmarks()' -n 1 -T 'self.local_bookmarks()' --no-graph)
    githead=$(jj -R ${SRC_ROOT} log -r "@-" --no-graph -T 'commit_id')

    if [ ! -d ${GIT_TMP} ]; then
	git clone -q -n ${GIT_MAIN} ${GIT_TMP}
    fi

    git -C ${GIT_MAIN} tag -f ninja-tmp ${githead}

    git -C ${GIT_TMP} remote update
    git -C ${GIT_TMP} fetch origin +refs/tags/ninja-tmp:refs/tags/ninja-tmp

    # This builds the kernel identifier with the correct branch name,
    # even if there are later commits.
    git -C ${GIT_TMP} checkout ${branchname}
    git -C ${GIT_TMP} reset --hard ninja-tmp

    git -C ${GIT_MAIN} tag -d ninja-tmp > /dev/null

    # double check that the git repo isn't dirty somehow
    if [ -n "$(git -C ${GIT_TMP} status --porcelain)" ]; then
	echo "E: refusing to build a dirty tree"
	exit 1
    fi

    SRC_ROOT=$(realpath ${GIT_TMP})
}

ensure_not_dirty() {
    set +o pipefail
    if ! jj -R ${REPO_ROOT} status --quiet | grep -q '^Working copy .* (empty) (no description set)'; then
	echo "E: refusing to build in a dirty tree"
	exit 1
    fi
    set -o pipefail
}

parse_args() {
    local tree

    CMD=${1}; shift
    CONFIG=${1}; shift

    . $(realpath ${CONFIG})

    SRC_ROOT=$(realpath ${TREE})
    REPO_ROOT=${SRC_ROOT}

    case ${CMD} in
	build|clean|objdir|ls-files)
	    ;;
	*)
	    echo "E: unknown command ${CMD}" 1>&2
	    exit 1
	    ;;
    esac

    __MAKE_CONF=/dev/null
    SRCCONF=$(realpath src.conf)
    OBJROOT=$(pwd)/_build/$(basename ${CONFIG} .conf)/
    CCACHE_CONFIGPATH=$(realpath ccache.conf)
}

# Build and release all in one go so the git ref is consistent.  Clean
# because we're reusing a temp git dir, which can cause issues as we
# juggle versions.
cmd::build() {
    _make cleanworld
    _make buildworld buildkernel

    SRC_ROOT=$(realpath ${SRC_ROOT}/release)
    _make -DNOPORTS packagesystem
}

cmd::clean() {
    _make cleanworld
}

cmd::objdir() {
    _make -V .OBJDIR
}

cmd::ls-files() {
    jj -R ${SRC_ROOT} file list
}

_make() {
    __MAKE_CONF=${__MAKE_CONF} \
	       SRCCONF=${SRCCONF} \
	       OBJROOT=${OBJROOT} \
	       CCACHE_CONFIGPATH=${CCACHE_CONFIGPATH} \
	       make \
	       -C ${SRC_ROOT} \
	       -s \
	       -j$(sysctl -n hw.ncpu) \
	       -DNO_ROOT ${@}
}

main "${@}"
