{ config, lib, pkgs, ... }:

{
  imports = [
    ../common.nix
    ./_desktop.nix
    ../hardware-configuration/doyha.nix
  ];

  config = {
    host.name = "doyha";
    host.class ="desktop";
    host.boot-type = "efi";
    host.samba.enable = true;
    host.doyha-backups.enable = true;
    nix.buildCores = 6;
    services.exim.enable = true;

    host.pulseaudio.enable = true;
    #hardware.pulseaudio.systemWide = true;
    hardware.pulseaudio.daemon.config = { flat-volumes = "no"; };
    hardware.pulseaudio.extraClientConf = ''
      default-server = /var/run/pulse/native
    '';
    environment.etc."pulse/alsa-mixer/paths/analog-output.conf.common".text = ''
      [Element Front]
      volume = ignore
      [Element Master]
      volume = ignore
      [Element PCM]
      volume = ignore
    '';
    users.groups.audio.members = [ "root" "edanaher" ];
    users.groups.lp.members = [ "pulse" "edanaher" ];

    host.virtualbox.enable = false;

    services.openssh.forwardX11 = true;
    networking.firewall.allowedTCPPorts = [ 445 139 ];  # Samba
    networking.firewall.allowedUDPPorts = [ 137 138 ];  # Samba
    networking.firewall.allowedTCPPortRanges = [
      { from = 6945; to = 6949; }  # bittorrent
      { from = 9875; to = 9875; }  # ad-hoc pashare
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

    systemd.timers.check-edanaher-mail = {
      description = "Check mail for edanaher every half hour";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* *:00,30:00";
        Persistent = true;
      };
    };

    hardware.opengl.driSupport32Bit = true;

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

    services.atd.enable = true;

    # *sigh*
    services.postgresql.enable = true;

    users.extraUsers.kduncan = {
      uid = 1001;
    };
  };
}
