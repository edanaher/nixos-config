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
    nix.settings.cores = 6;
    services.exim.enable = true;
    host.superset.enable = true;

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
    users.groups.dialout.members = [ "edanaher" ];
    users.groups.exim.members = [ "exim" "edanaher" ];

    host.virtualbox.enable = false;
    virtualisation.waydroid.enable = true;
    #virtualisation.anbox.enable = true;
    #virtualisation.anbox.extraInit = "export DISPLAY=:5";

    services.openssh.forwardX11 = true;
    networking.firewall.allowedTCPPorts = [ 80 445 139 24800 ];  # Samba, Barrier
    networking.firewall.allowedUDPPorts = [ 137 138 ];  # Samba
    networking.firewall.allowedTCPPortRanges = [
      { from = 6945; to = 6949; }  # bittorrent
      { from = 9875; to = 9875; }  # ad-hoc pashare
    ];

    networking.extraHosts = ''
      192.168.12.204 deretheni-old
      192.168.12.128 deretheni
      169.254.94.126 gemedetw
      127.0.0.1      superset
      127.0.0.1      superset.local
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

    programs.adb.enable = true;
    users.users.edanaher.extraGroups = ["adbusers"];

    services.minidlna = {
      enable = false;
      announceInterval = 60;
      mediaDirs = [ "/mnt/bak/deretheni/camera-all/" ];
    };

    # *sigh*
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_11;
      ensureUsers = [{
        name = "edanaher";
        ensurePermissions = { "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES"; };
      }];
      ensureDatabases = [ "edanaher" ];
    };

    users.extraUsers.kduncan = {
      isNormalUser = true;
      uid = 1001;
    };

    services.xserver.serverFlagsSection = ''
      Option "MaxClients" "2048"
    '';

    services.yubikey-agent.enable = true;
    services.pcscd.enable = true;


    #services.dnsmasq = {
    #  enable = true;
    #  extraConfig = ''
    #    address=/superset/192.168.122.1
    #  '';
    #  servers = [ "75.75.75.75" "76.76.76.76" "4.2.2.1" "1.1.1.1" ];
    #};

    #programs.steam.enable = true;
    #nixpkgs.config.packageOverrides = pkgs: {
    #  steam = pkgs.steam.override {
    #    nativeOnly = true;
    #  };
    #};
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
         "steam"
         "steam-original"
         "steam-runtime"
         "steam-run"
       ];
  };
}
