{config, lib, pkgs, ...}:

let
  utils = import ../utils.nix;
  escapeSlash = builtins.replaceStrings [ "/" ] [ "_" ];
  mon-script-template = builtins.readFile ./disk-mon.sh;
  mon-script-text = disk: usage: builtins.replaceStrings [ "$DISK" "$USAGE" ] [ disk usage ] mon-script-template;
  mon-script-for = disk: usage: pkgs.writeScript ("disk-mon-" + escapeSlash disk + "-" + usage) (mon-script-text disk usage);
  mon-service-for = disk: usage: {
      description = "Monitor usage for ${disk} at ${toString usage}";
      path = with pkgs; [ exim ];
      serviceConfig = {
        User = "root";
        Group = "root";
        ExecStart = "${mon-script-for disk (toString usage)}";
        Restart = "on-failure";
        RestartSec = "4h";
      };
    };

  mon-timer-for = disk: usage: utils.simple-timer "daily" "Monitor usage for ${disk} at ${toString usage} daily";

  services = lib.mapAttrs' (disk: usage: lib.nameValuePair ("monitor-disk-" + escapeSlash disk) (mon-service-for disk usage)) config.host.monitor-disks;
  timers = lib.mapAttrs' (disk: usage: lib.nameValuePair ("monitor-disk-" + escapeSlash disk) (mon-timer-for disk usage)) config.host.monitor-disks;
in
{
  config = lib.mkIf (config.host.monitor-disks != null) {
    systemd.services = services;
    systemd.timers = timers;
  };

  options = {
    host.monitor-disks = lib.mkOption {
      type = with lib.types; nullOr (attrsOf int);
      default = null;
      description = ''
        List of disks to monitor for usage.
      '';
    };
  };
}
