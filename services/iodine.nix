{config, lib, pkgs, ...}:

let secrets = import ../secrets.nix; in
{
  config = lib.mkIf config.host.iodine.enable {
    services.iodine.server = {
      enable = true;
      domain = "i2.kdf.sh";
      ip = "10.70.1.1";
      extraConfig = "-c -P ${secrets.iodine.password} -p 5392";
    };
  };

  options = {
    host.iodine.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable iodine DNS tunnel
      '';
    };
  };
}
