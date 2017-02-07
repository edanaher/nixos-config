{config, lib, pkgs, ...}:

let
  utils = import ./utils.nix { inherit lib; };
  hosts = {
    "chileh" = {
      host.class ="desktop";
      nix.buildCores = 4;
      services.exim.enable = true;
    };
    "kroen" = {
      nix.buildCores = 4;
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
    };
    "gemedet" = {
      nix.buildCores = 8;
      host.class ="laptop";
    };
  };
  classes = {
    "laptop" = {
      security.sudo.configFile= ''
        edanaher ALL=(ALL) NOPASSWD: /home/edanaher/bin/bin/_set_brightness.sh
        edanaher ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/rfkill
      '';
    };
    "desktop" = {
    };
    "server" = {

    };
  };
  hostconfig = utils.select config.host.name hosts;
  classconfig = utils.select config.host.class classes;
in
  lib.mkMerge [ hostconfig classconfig ]