{ config, lib, pkgs, ... }:

let cfg = config.host.exim;
    secrets = import ../../secrets.nix;
    smtp-to-xmpp = import /home/edanaher/smtp-to-xmpp { inherit pkgs; };
    client-config = lib.mkIf (cfg.enable && cfg.class == "client")  {
      services.exim.config = import ./client-conf.nix { inherit secrets; };
    };
    server-config = lib.mkIf (cfg.enable && cfg.class == "server") {
      services.exim.config = import ./kdfsh-conf.nix { inherit smtp-to-xmpp; };
      security.acme.certs."exim-kdf.sh" ={
        domain = "kdf.sh";
        user = "root";
        group = "exim";
        allowKeysForGroup = true;
        webroot = config.security.acme.certs."kdf.sh".webroot;
        postRun = "systemctl reload exim";
      };
      services.rspamd.enable = true;
      services.rmilter.enable = false;
    };
in
{
  config = lib.mkMerge [ client-config server-config ];

  options = {
    host.exim = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable exim";
      };
      class = lib.mkOption {
        type = lib.types.enum [ "server" "client" ];
        description = "Select mail server (receiving/storing/sending) or local (sending from localhost only)";
      };
    };
  };
}
