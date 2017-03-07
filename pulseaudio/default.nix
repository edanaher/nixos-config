{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.host.pulseaudio.enable {
    hardware.pulseaudio.enable = true;
    hardware.pulseaudio.package = pkgs.pulseaudioFull;
    hardware.bluetooth.enable = true;
    hardware.pulseaudio.configFile = ./default.pa;
  };
}
