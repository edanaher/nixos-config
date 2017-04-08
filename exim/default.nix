{ config, lib, pkgs, ... }:

let secrets = import ../secrets.nix;
    smtp-to-xmpp = import /home/edanaher/smtp-to-xmpp { inherit pkgs; };
    client-config = lib.mkIf (config.host.class != "server") {
      services.exim.config = import ./client-conf.nix { inherit secrets; };
    };
    server-config = lib.mkIf (config.host.name == "kdfsh") {
      services.exim.config = import ./kdfsh-conf.nix { inherit smtp-to-xmpp; };
      security.acme.certs."exim-kdf.sh" ={
        domain = "kdf.sh";
        user = "root";
        group = "exim";
        allowKeysForGroup = true;
        webroot = config.security.acme.certs."kdf.sh".webroot;
        postRun = "systemctl reload exim";
      };
    };
in
{
  config = lib.mkMerge [ client-config server-config ];
}
