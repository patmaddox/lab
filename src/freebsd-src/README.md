# freebsd-src

This package provides a simple way to produce FreeBSD releases.
It produces `base.txz` and `kernel.txz`, as well as a `pkgbase` repo.

Example release definition:

```python
freebsd_release(name = "rel--stabweek-2024-10", version = "525a177c1657")
```

## Notes

`scripts/build.sh` runs all of the steps needed to produce the
artifacts, in one go.

I tried splitting up the stages, so that `buildworld buildkernel` ran
first, and the distribution targets could depend on it.
This would make it possible to change the distribution targets without
triggering a complete rebuild.

However, it seems that the build process creates symlinks to absolute
paths.
When `plz` moves the output out of the tmp dir, it breaks the symlink
and the distribution targets fail.

## TODO

- [ ] speed up the build using CCACHE, memdisk, etc - [vermaden article](https://vermaden.wordpress.com/2023/12/09/personal-freebsd-pkgbase-update-server/)
