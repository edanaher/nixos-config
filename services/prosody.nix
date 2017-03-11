{config, lib, pkgs, ...}:

let kdf-plugins = import /home/edanaher/prosody-mod { inherit pkgs; };
in
{
  config = lib.mkIf (config.host.name == "kdfsh") {
    services.prosody = {
      enable = true;
      modules.bosh = true;
      extraModules = [ "vcard" ];
      extraConfig = ''
        plugin_paths = { "${kdf-plugins}" }
      '';
      virtualHosts = {
        "kdf.sh" = {
          domain = "kdf.sh";
          ssl.key = "/var/lib/acme/kdf.sh/key.pem";
          ssl.cert = "/var/lib/acme/kdf.sh/fullchain.pem";
          enabled = true;
          extraConfig = ''
            Component "smtp.kdf.sh" "kdf-sh"
          '';
        };
      };
    };
  };
}
