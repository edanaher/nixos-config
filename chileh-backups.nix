{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.host.chileh-backups.enable {
    systemd.services.backup-deretheni = {
      description = "Backup deretheni";
      path = with pkgs; [ borgbackup bup rsync openssh ];
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

    systemd.services.snapshot-chileh-edanaher = {
      description = "Snapshot chileh homedir";
      path = with pkgs; [ btrfs-progs ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        User = "root";
        ExecStart = "/home/edanaher/bin/bin/do_snapshot_home";
      };
    };

    systemd.timers.snapshot-chileh-edanaher = {
      description = "Snapshot chileh homedir hourly";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };

    systemd.services.snapshot-chileh-edanaher-to-borg = {
      description = "Copy chileh homedir snapshots to borg";
      path = with pkgs; [ bash borgbackup utillinux ];
      serviceConfig = {
        User = "root";
        ExecStart = "/mnt/snapshots-borg/borg/do.sh";
      };
    };

    systemd.timers.snapshot-chileh-edanaher-to-borg = {
      description = "Copy chileh homedir snapshots to borg daily";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };

  options = {
    host.chileh-backups = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Run chileh backup scripts";
      };
    };
  };
}
