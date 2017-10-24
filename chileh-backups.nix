{ config, lib, pkgs, ... }:

let two-days = 60 * 60 * 24 * 2 - 60;
    utils = import ./utils.nix;
in
{
  config = lib.mkIf config.host.chileh-backups.enable {
    services.periodimail.intervals = [ two-days ];
    systemd.services.backup-deretheni = {
      description = "Backup deretheni";
      path = with pkgs; [ borgbackup bup rsync openssh ];
      wants = [ "network-online.target" ];
      unitConfig = {
        OnFailure = "periodimail-${builtins.toString two-days}@%n.service";
      };
      serviceConfig = {
        User = "edanaher";
        Group = "users";
        ExecStart = "/mnt/bak/deretheni/do.sh";
        Restart = "on-failure";
        RestartSec = "1h";
      };
    };

    systemd.timers.backup-deretheni = utils.simple-timer "daily" "Backup deretheni daily";

    systemd.services.snapshot-chileh-edanaher = {
      description = "Snapshot chileh homedir";
      path = with pkgs; [ btrfs-progs ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        User = "root";
        ExecStart = "/home/edanaher/bin/bin/do_snapshot_home";
      };
    };

    systemd.timers.snapshot-chileh-edanaher = utils.simple-timer "hourly" "Snapshot chileh homedir hourly";

    systemd.services.snapshot-chileh-edanaher-to-borg = {
      description = "Copy chileh homedir snapshots to borg";
      path = with pkgs; [ bash borgbackup utillinux ];
      serviceConfig = {
        User = "root";
        ExecStart = "/mnt/snapshots-borg/borg/do.sh";
      };
    };

    systemd.timers.snapshot-chileh-edanaher-to-borg = utils.simple-timer "daily" "Copy chileh homedir snapshots to borg daily";
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
