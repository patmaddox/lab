# beastie

`doas ./install.sh`

zfs snapshots look like:

```
beastie-14.2-2024-12-01
  @empty
  @freebsd
  @freebsd_config
  @packages
  @packages_config
  @data
```
1. Create a new boot environment
2. Install FreeBSD
3. Install packages
4. Install configuration files
5. Restore data from backup (passwd, SSH keys, etc)

Restoring data isn't really a unique step.
It's all just a matter of "install from [src] to [dst]".
Many of the installation steps are simply copying files, perhaps using `tar`.
Other steps use my custom commands, like `sync-pw` or whatever it is.
