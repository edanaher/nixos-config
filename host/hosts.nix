{config, lib, pkgs, ...}:

let
  utils = import ./utils.nix { inherit lib; };
  udev-keyboard-autoplug = import ../scripts/udev-keyboard-autoplug.nix;
  acpid-script = import ../scripts/acpid-script.nix;
  hosts = {
    "chileh" = {
      host.class ="desktop";
      host.boot-type = "bios";
      host.chileh-backups.enable = true;
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
        "/" = 90;
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
      nix.buildCores = 4;
      networking.hostId = "65c89bd7";
      host.class ="laptop";
      services.exim.enable = true;

      services.xserver.synaptics.enable = true;

      services.xserver.synaptics.accelFactor = "0.05";
      services.xserver.synaptics.minSpeed = "1";
      services.xserver.synaptics.maxSpeed = "2.5";
      services.xserver.synaptics.twoFingerScroll = true;
      services.xserver.synaptics.vertEdgeScroll = true;
      services.xserver.synaptics.additionalOptions = ''
        Option "VertScrollDelta" "16"
        Option "RTCornerButton" "3"
        Option "TapButton2" "3"
        Option "TapButton3" "2"
        Option "ClickFinger2" "3"
        Option "ClickFinger3" "2"
        Option "CircularScrolling" "1"
        Option "CircScrollTrigger" "2"
        Option "RightButtonAreaLeft" "560"
        Option "RightButtonAreaTop" "400"
        Option "MiddleButtonAreaLeft" "460"
        Option "MiddleButtonAreaRight" "559"
        Option "MiddleButtonAreaTop" "400"
      '';

      services.udev.packages = [ udev-keyboard-autoplug ];
      services.udev.extraRules = ''
        ACTION=="add", ATTRS{idVendor}=="06cb", ATTRS{idProduct}=="2819", RUN+="${udev-keyboard-autoplug}/bin/udev-keyboard-autoplug.sh"
      '';

      host.touchscreen = true;
    };
    "gemedet" = {
      nix.buildCores = 8;
      host.class ="laptop";

      nix.trustedBinaryCaches = [ https://bob.logicblox.com ];
      nix.requireSignedBinaryCaches = false;

      boot.blacklistedKernelModules = [ "radeon" ];
    };
    "kdfsh" = {
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
    };
  };
  hostconfig = utils.select config.host.name hosts;
in
{
  config = hostconfig;
}
