{config, lib, pkgs, ...}:

{
  config = lib.mkIf (config.host.name == "kdfsh") {
    services.dovecot2 = {
      enable = true;
      enableImap = true;
      # Certs are generated in kdf-nginx.nix under kdf.sh hostname.
      sslServerKey = "/var/lib/acme/kdf.sh/key.pem";
      sslServerCert = "/var/lib/acme/kdf.sh/fullchain.pem";
      mailLocation = "maildir:~/.maildir:LAYOUT=fs";
    };
    security.acme.certs."kdf.sh".user = "prosody";
    security.acme.certs."kdf.sh".group = "exim";
    security.acme.certs."kdf.sh".allowKeysForGroup = true;
  };
}
