{config, lib, pkgs, ...}:

let
  utils = import ./utils.nix { inherit lib; };
  udev-keyboard-autoplug = import ../scripts/udev-keyboard-autoplug.nix;
  hosts = {
    "doyha" = {};
    "chileh" = {
      host.class ="desktop";
      host.boot-type = "bios";
      #host.chileh-backups.enable = true;
      nix.buildCores = 4;
      services.exim.enable = true;


      services.openssh.forwardX11 = true;
      networking.firewall.allowedTCPPortRanges = [
        { from = 6945; to = 6949; }  # bittorrent
      ];

      networking.extraHosts = ''
        192.168.12.205 deretheni
        169.254.94.126 gemedetw
      '';

      systemd.services.check-edanaher-mail = {
        description = "Check mail for edanaher";
        path = [ pkgs.fetchmail pkgs.procmail ];
        serviceConfig = {
          Type = "oneshot";
          User = "edanaher";
          ExecStart = "/home/edanaher/bin/bin/run_fetchmail";
        };
      };

      systemd.timers.check-edanaher-mail = utils.simple-timer "*-*-* *:00,30:00" "Check mail for edanaher every half hour";

      host.monitor-disks = {
        "/" = 80;
        "/mnt/movies" = 95;
        "/mnt/bak" = 90;
        "/boot" = 90;
        "/mnt/data" = 95;
        "/mnt/old" = 90;
        "/mnt/snapshots" = 90;
        "/mnt/snapshots-borg" = 90;
      };
    };
    "kroen" = {
    };
    "gemedet" = {
      nix.buildCores = 8;
      host.class ="laptop";

      nix.trustedBinaryCaches = [ https://bob.logicblox.com ];
      nix.requireSignedBinaryCaches = false;

      boot.blacklistedKernelModules = [ "radeon" ];
    };
    "kdfsh" = {};
  };
  hostconfig = utils.select config.host.name hosts;
in
{
  config = hostconfig;
}
