{ config, lib, pkgs, ... }:

{
  services.fcron.enable = true;
  services.fcron.systab = ''
    0 * * * * /mnt/snapshots/do.sh
    #37 1 * * * { umount /mnt/snapshots && mount /mnt/snapshots; } >/dev/null 2>&1
  '';

  systemd.services.backup-deretheni = {
    description = "Backup deretheni";
    path = with pkgs; [ bup rsync openssh ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      User = "edanaher";
      Group = "users";
      ExecStart = "/mnt/bak/deretheni/do.sh";
      Restart = "on-failure";
      RestartSec = "1h";
    };
  };

  systemd.timers.backup-deretheni = {
    description = "Backup deretheni daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

}
