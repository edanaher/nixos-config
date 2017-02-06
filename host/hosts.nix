{config, lib, pkgs, ...}:

let
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
  hostconfigs = lib.mapAttrs (name: host: lib.mkIf (name == config.host.name) host) hosts;
  hostconfig = lib.mkMerge (builtins.attrValues hostconfigs);
  classconfigs = lib.mapAttrs (name: class: lib.mkIf (name == "desktop") class) classes;
  classconfig = lib.mkMerge (builtins.attrValues classconfigs);
in
  lib.mkMerge [ hostconfig classconfig ]
