{ config, lib, pkgs, ... }:

let two-days = 60 * 60 * 24 * 2 - 60;
    periodimail = import ./scripts/periodimail.nix { inherit pkgs; };
    utils = import ./utils.nix;
in
{
  config = lib.mkIf config.host.chileh-backups.enable {
    systemd.services.backup-deretheni = {
      description = "Backup deretheni";
      path = with pkgs; [ borgbackup bup rsync openssh exim ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        User = "edanaher";
        Group = "users";
        ExecStart = periodimail.wrap { interval = two-days; script = "/mnt/bak/deretheni/do.sh"; service = "backup-deretheni"; };
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
        ExecStart = periodimail.wrap { interval = two-days; script = "/home/edanaher/bin/bin/do_snapshot_home"; service = "snapshot-chileh-edanaher"; };
      };
    };

    systemd.timers.snapshot-chileh-edanaher = utils.simple-timer "hourly" "Snapshot chileh homedir hourly";

    systemd.services.snapshot-chileh-edanaher-to-borg = {
      description = "Copy chileh homedir snapshots to borg";
      path = with pkgs; [ bash borgbackup utillinux exim ];
      serviceConfig = {
        User = "root";
        ExecStart = periodimail.wrap { interval = two-days; script = "/mnt/snapshots-borg/borg/do.sh"; service = "snapshot-chileh-edanaher-to-borg"; };
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
