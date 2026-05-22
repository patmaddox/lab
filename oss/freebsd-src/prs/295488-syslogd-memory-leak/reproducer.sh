#!/bin/sh
# Demonstrate memory leak in casper_ttymsg(). Messages routed to
# /dev/console go through casper_ttymsg, which leaks. Messages
# routed to a file do not. The test config uses priority level to
# steer messages to each destination.

PIDFILE=/tmp/leak-test.pid
CONF=/tmp/leak-test.conf
LOGFILE=/tmp/leak-test.log
#N=500000
#N=150000
N=10000
#N=5

cleanup() {
	if [ -f "$PIDFILE" ]; then
		kill "$(cat "$PIDFILE")" 2>/dev/null
		rm -f "$PIDFILE"
	fi
}
trap 'cleanup; service syslogd start' EXIT

service syslogd stop

rm -f ${LOGFILE}
touch ${LOGFILE}

cat > "$CONF" <<EOF
*.err		/dev/console
*.info		${LOGFILE}
EOF

run_test() {
	pri=$1
	dest=$2
	echo "--- $N $pri messages to $dest ---"
	syslogd -F -ss -f "$CONF" -P "$PIDFILE" &
	sleep 2

	i=0
	while [ "$i" -lt "$N" ]; do
		logger -p "$pri" "test $i"
		i=$((i + 1))
	done

	echo "casper RSS (KB):"
	ps -ax -o rss,command | grep '[s]yslogd\.casper'

	kill "$(cat "$PIDFILE")"
	wait
	rm -f "$PIDFILE"
	echo ""
}

cleanup
run_test user.info ${LOGFILE}
run_test user.err /dev/console
