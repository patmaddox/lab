{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./minimal.nix
    ];

  virtualisation.docker.enable = true;
}
