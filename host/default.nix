{config, lib, pkgs, ... }:

with lib;

let
  cfg = config.host;
in
{
  imports = [ ./hosts.nix ];
  options.host = {
    name = mkOption {
      type = types.str;
      description = ''
        Host name.  Used for config.networking.hostName and to determine other
        options.
      '';
    };
    class = mkOption {
      type = types.enum [ "laptop" "desktop" "server" ];
      description = ''
        Class of machine; used to pick reasonable defaults
      '';
    };
    touchscreen = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether or not the host has a touchscreen; enables relevant features.
      '';
    };
  };


}
