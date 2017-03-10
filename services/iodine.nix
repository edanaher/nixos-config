{config, lib, pkgs, ...}:

let secrets = import ../secrets.nix; in
{
  config = lib.mkIf (config.host.name == "kdfsh") {
    services.iodine.server = {
      enable = true;
      domain = "i2.kdf.sh";
      ip = "10.70.1.1";
      extraConfig = "-cP ${secrets.iodine.password} -p 5392";
    };
  };
}
