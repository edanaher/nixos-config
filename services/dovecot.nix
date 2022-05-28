{config, lib, pkgs, ...}:

{
  config = lib.mkIf config.host.dovecot.enable {
    services.dovecot2 = {
      enable = true;
      enableImap = true;
      # Certs are generated in kdf-nginx.nix under kdf.sh hostname.
      # TODO: once the kdf.sh ratelimit on letsencrypt times out, update this.
      sslServerKey = "/var/lib/acme/dovecot-kdf.sh/key.pem";
      sslServerCert = "/var/lib/acme/dovecot-kdf.sh/fullchain.pem";
      mailLocation = "maildir:~/.maildir:LAYOUT=fs";
    };
    security.acme.certs."dovecot-kdf.sh" ={
      domain = "kdf.sh";
      group = "dovecot2";
      webroot = config.security.acme.certs."kdf.sh".webroot;
      postRun = "systemctl reload dovecot2";
      email = "dovecotcert@kdf.sh";
    };
  };

  options = {
    host.dovecot.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable dovecot serving IMAP.
      '';
    };
  };
}
