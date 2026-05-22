# syslogd: memory leak in casper_ttymsg() via nvlist_take_string_array

https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=295488

**Category:** Base System / bin

**Version:** FreeBSD 15.0-RELEASE (also present on main)

## Description

`casper_ttymsg()` in `usr.sbin/syslogd/syslogd_cap_log.c` leaks the
string array returned by `nvlist_take_string_array()`. The function
takes ownership of both the array pointer and the individual strings,
but only frees the `iov` wrapper. The strings and array itself are
never freed.

This leaks memory on every F_CONSOLE and F_TTY log message
(e.g. anything matching `*.err` routed to `/dev/console` in the
default syslog.conf). On long-running systems, the `syslogd.casper`
child process grows to hundreds of MB.

The sibling function `casper_wallmsg()` in the same file handles
cleanup correctly and can serve as a reference for the fix.

## How to reproduce

See attached script (`reproducer.sh`).

## Observed in production

Two FreeBSD 15.0 haproxy servers with 106 days uptime showed
`syslogd.casper` at 205MB and 49MB RSS respectively. Non-haproxy
servers (low error-rate syslog traffic) stayed at 3-4MB. Restarting
syslogd returns RSS to baseline.

## Introduced in

Commit 61a29eca550b ("syslogd: Log messages using libcasper")

## Reproducer

### before

```
root@devbsd:~/lab/default.jj/oss/freebsd-src/default.jj/usr.sbin/syslogd # ../../../prs/freebsd-mem-leak/leak-test.sh
syslogd not running? (check /var/run/syslog.pid).
--- 150000 user.info messages to /tmp/leak-test.log ---
casper RSS (KB):
2676 syslogd: syslogd.casper (syslogd)

--- 150000 user.err messages to /dev/console ---
casper RSS (KB):
31336 syslogd: syslogd.casper (syslogd)

Starting syslogd.
```

### after

```
root@devbsd:~/lab/default.jj/oss/freebsd-src/default.jj/usr.sbin/syslogd # PATH=$(make -V .OBJDIR):$PATH ../../../prs/freebsd-mem-leak/leak-test.sh
syslogd not running? (check /var/run/syslog.pid).
--- 150000 user.info messages to /tmp/leak-test.log ---
casper RSS (KB):
2680 syslogd: syslogd.casper (syslogd)

--- 150000 user.err messages to /dev/console ---
casper RSS (KB):
2684 syslogd: syslogd.casper (syslogd)

Starting syslogd.
```
