# nixos on bhyve

1. Install nixos
2. Paste minimal config
3. Upload and rebuild full config

Run vm-bhyve in install mode:

`vm install -i nixos nixos-minimal.iso`

In the installer grub loader, select `HiDPI, Quirks and Accessibility`
and then choose `Serial console=ttyS0,115200n8`.

Once in the installer, run everything as root:

`sudo su`

Disk prep:

```sh
parted /dev/vda -- mklabel gpt
parted /dev/vda -- mkpart root ext4 512MB 100%
parted /dev/vda -- mkpart ESP fat32 1MB 512MB
parted /dev/vda -- set 2 esp on

mkfs.ext4 -L nixos /dev/vda1
mkfs.fat -F 32 -n boot /dev/vda2

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot

nixos-generate-config --root /mnt
```

Now edit `/mnt/etc/nixos/configuration.nix` - in my case, replace it
with the contents of `minimal.nix`.

Install with passwordless root. You still have to delete the root
user's password, otherwise it will not be possible to log in.

```
nixos-install --no-root-password
nixos-enter --root /mnt -c 'passwd -d root'
```

Should be good to go:

```
shutdown -r now
```
