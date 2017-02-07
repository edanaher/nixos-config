{ config, lib, pkgs, ... }:

let
  # This is hacky; see comment below.
  hostname = (import ../hostname.nix).host.name;
in
{
  imports = [ (builtins.toPath "/etc/nixos/hardware-configuration/${hostname}.nix") ];
}

/*
#This is the "right" way to do it, but fails, I believe due to an interaction of mkIf with imports.
let
  hostutils = import ../host/utils.nix { inherit lib; };
  hardware_for = host: import (builtins.toPath "/etc/nixos/hardware-configuration/${host}.nix") { inherit config lib pkgs; };
  hardwares_list = map (h: { name = h; value = hardware_for h; }) [ "chileh" "kroen" ];
  hardware = hostutils.select config.host.name (builtins.listToAttrs hardwares_list);
in
  hardware
*/
