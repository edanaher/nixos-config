{ config, lib, pkgs, ... }:

let secrets = import ../secrets.nix;
in
{
  config = lib.mkIf (config.host.class != "server") {
    services.exim.config = import ./client-conf.nix { inherit secrets; };
  };
}
