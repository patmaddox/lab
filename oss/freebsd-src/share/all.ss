SRC_ROOT="$(realpath "$(pwd)/../..")"
config="$(basename "$(pwd)")"

. ./config

export SRC_ROOT
export CCACHE_CONFIGPATH="${SRC_ROOT}/ccache.conf"
export JJ_ROOT="$(realpath "${SRC_ROOT}/default.jj")"
export KERNCONF="${kernel}"
export SRCCONF="$(realpath "${SRC_ROOT}/src.conf")"
unset MAKEFLAGS

stamp rev_stamp

target buildworld _build
needs : rev_stamp config "${SRC_ROOT}/share/build.sh" "${SRC_ROOT}/share/build-common.sh"

target buildkernel _build
needs : buildworld

target pkgbase _build
needs : buildworld buildkernel

target vm_image build_vm_image
needs : pkgbase "${SRC_ROOT}/share/vm-nodbg32.conf"

rev_stamp() {
	jj -R "${JJ_ROOT}" --ignore-working-copy show -r "${rev}" -T 'commit_id' --tool true > "${outfile}"
}

_build() {
	local sha
	sha="$(jj -R "${JJ_ROOT}" --ignore-working-copy show -r "${rev}" -T 'commit_id' --tool true)"
	local tmplog="/tmp/freebsd-build.${config}.${target}.log"
	"${SRC_ROOT}/share/build.sh" "${target}" "${config}" "${sha}" \
		2>&1 | tee "${tmplog}"
	cp "${tmplog}" "${outfile}"
}

build_vm_image() {
	export VM_IMAGE_CONFIG="${SRC_ROOT}/share/vm-nodbg32.conf"
	_build
}
