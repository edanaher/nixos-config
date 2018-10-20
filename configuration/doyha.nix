{ config, lib, pkgs, ... }:

{
  imports = [
    ../common.nix
    ../hardware-configuration/doyha.nix
  ];

  config = {
    host.name = "doyha";
  };

}
