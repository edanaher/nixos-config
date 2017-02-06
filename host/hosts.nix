{config, lib, pkgs, ...}:

let
  utils = import ./utils.nix { inherit lib; };
  hosts = {
    "chileh" = {
      host.class ="desktop";
      nix.buildCores = 4;
      services.exim.enable = true;
    };
    "kroen" = {
      nix.buildCores = 4;
      host.class ="laptop";
    };
    "gemedet" = {
      nix.buildCores = 8;
      host.class ="laptop";
    };
  };
  classes = {
    "laptop" = {

    };
    "desktop" = {
    };
    "server" = {

    };
  };
  hostconfig = utils.select config.host.name hosts;
  classconfig = utils.select config.host.class classes;
in
  lib.mkMerge [ hostconfig classconfig ]
