#!/bin/sh
ssh root@nixos "mkdir -p next-config"
scp *.nix root@nixos:next-config
ssh root@nixos "cp /etc/nixos/hardware-configuration.nix next-config/ && nixos-rebuild -I nixos-config=next-config/configuration.nix switch && mv next-config/*.nix /etc/nixos/"
