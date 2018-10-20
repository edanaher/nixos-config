{ config, lib, pkgs, ... }:

let
  udev-keyboard-autoplug = import ../scripts/udev-keyboard-autoplug.nix;
in
{
  imports = [
    ../common.nix
    ../hardware-configuration/kroen.nix
  ];

  config = {
    host.name = "kroen";
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

}
