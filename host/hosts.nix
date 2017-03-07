{config, lib, pkgs, ...}:

let
  utils = import ./utils.nix { inherit lib; };
  udev-keyboard-autoplug = import ../scripts/udev-keyboard-autoplug.nix;
  acpid-script = import ../scripts/acpid-script.nix;
  hosts = {
    "chileh" = {
      host.class ="desktop";
      host.boot-type = "bios";
      nix.buildCores = 4;
      services.exim.enable = true;

      networking.extraHosts = ''
        192.168.12.205 deretheni
        169.254.94.126 gemedetw
      '';
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
  };
  classes = {
    "laptop" = {
      security.sudo.extraConfig = ''
        edanaher ALL=(ALL) NOPASSWD: /home/edanaher/bin/bin/_set_brightness.sh
        edanaher ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/rfkill
      '';

      services.acpid.enable = true;
      services.acpid.lidEventCommands = "${acpid-script}/bin/acpid-script.sh";
      services.logind.extraConfig = "HandleLidSwitch=ignore";

      services.tlp.enable = true;
      services.tlp.extraConfig = ''
        RESTORE_DEVICE_STATE_ON_STARTUP=1
      '';
    };
    "desktop" = {
    };
    "server" = {
      host.xserver.enable = false;
    };
  };
  hostconfig = utils.select config.host.name hosts;
  classconfig = utils.select config.host.class classes;
  # TODO: directly using hostname.nix because of imports and infinite recursion and mkIf fail.
  hostimports = if (import ../hostname.nix).host.name == "chileh" then [ ../snapshot.nix ] else [];
in
{
  imports = hostimports;
  config = lib.mkMerge [ hostconfig classconfig ];
}
