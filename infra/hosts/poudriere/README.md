# poudriere

## pkgbase jails

``` sh
poudriere jail -c -j 151amd64 -a amd64 -v 15 \
    -m pkgbase=base_release_1 \
    -U https://pkg.freebsd.org

poudriere jail -c -j 16amd64 -a amd64 -v 16 \
    -m pkgbase=base_latest \
    -U https://pkg.freebsd.org
```

https://lists.freebsd.org/archives/cu/2025-September/008763.html
https://lists.freebsd.org/archives/freebsd-pkgbase/2026-July/001530.html
