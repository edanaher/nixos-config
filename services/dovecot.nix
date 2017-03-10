{config, lib, pkgs, ...}:

{
  config = lib.mkIf (config.host.name == "kdfsh") {
    services.dovecot2 = {
      enable = true;
      enableImap = true;
      # TODO: Hook this up to letsencrypt.
      sslServerKey = "/mnt/debian/etc/dovecot/private/dovecot.pem";
      sslServerCert = "/mnt/debian/etc/dovecot/dovecot.pem";
      mailLocation = "mbox:~/mail:INBOX=~/.mbox";
    };
  };
}
