validate_users_and_groups() {
    for u in ${USERS}; do
	pw usershow ${u} > /dev/null
    done

    for g in ${GROUPS}; do
	pw groupshow ${g} > /dev/null
    done
}

sync_pw() {
    for u in ${USERS}; do
	${DOAS} ${INSTALLED_SYNC_PW} /etc ${TMPROOT}/etc u ${u}
    done

    for g in ${GROUPS}; do
	${DOAS} ${INSTALLED_SYNC_PW} /etc ${TMPROOT}/etc g ${g}
    done
}

sync_data_files() {
    ${DOAS} tar -C / -c @${DATA_MTREE} | ${DOAS} tar -C ${TMPROOT} -x
}
