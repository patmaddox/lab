validate_users_and_groups() {
    ssh ${HOSTNAME} "sh -s" <<EOF
set -eu
set -o pipefail

USERS="${USERS}"
GROUPS="${GROUPS}"

$(cat ${NEWBE_ROOT}/libexec/libnewbe.sh)

validate_users_and_groups
EOF
}

sync_pw() {
    ssh ${HOSTNAME} "sh -s" <<EOF
set -eu
set -o pipefail

DOAS=${DOAS}
INSTALLED_SYNC_PW=${INSTALLED_SYNC_PW}
TMPROOT=${TMPROOT}
USERS="${USERS}"
GROUPS="${GROUPS}"

$(cat ${NEWBE_ROOT}/libexec/libnewbe.sh)

sync_pw
EOF
}

sync_data_files() {
    ssh ${HOSTNAME} "sh -s" <<EOF
set -eu
set -o pipefail

DOAS=${DOAS}
TMPROOT=${TMPROOT}

(${DOAS} tar -C / -c @- <<MTREE
$(cat ${DATA_MTREE})
MTREE
) | ${DOAS} tar -C ${TMPROOT} -x
EOF
}
