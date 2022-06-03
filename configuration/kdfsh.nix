{ config, lib, pkgs, ... }:

{
  imports = [
    ../common.nix
    ./_server.nix
    ../hardware-configuration/kdfsh.nix
  ];

    config = {
      host.name = "kdfsh";
      host.class ="server";
      host.boot-type = "xen";
      host.kdf-services.enable = true;
      host.dovecot.enable = true;
      host.gritonputty.enable = true;
      host.iodine.enable = true;
      host.randomtoby.enable = true;
      host.caltrain.enable = true;
      host.lwt.enable = true;
      host.angell-classes.enable = true;
      host.nowaytopreventthis.enable = true;
      host.ctfwsinthepark.enable = true;

      networking.interfaces.eth0 = {
        ipv6Address = "2605:2700:0:5::4713:9cf2";
      };

      services.exim.enable = true;

      networking.firewall.allowedUDPPortRanges = [
        { from = 53; to = 53; }  # DNS (kdf-dns)
      ];
      networking.firewall.allowedTCPPortRanges = [
        { from = 25; to = 25; }  # SMTP (exim)
        { from = 587; to = 587; }  # SMTP (exim)
        { from = 80; to = 80; }  # HTTP (nginx)
        { from = 443; to = 443; }  # HTTPS (nginx)
        { from = 143; to = 143; }  # IMAP (dovecot)
        { from = 993; to = 993; }  # IMAP (dovecot)
        { from = 5269; to = 5269; }  # XMPP (prosody)
        { from = 5222; to = 5222; }  # XMPP (prosody)
      ];

      security.acme.email = "ssl@edanaher.net";
      security.acme.acceptTerms = true;

      system.stateVersion = "18.09";

    };

}
