{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.host.pulseaudio.enable {
    hardware.pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
    };
    hardware.bluetooth.enable = true;
    hardware.bluetooth.settings = {
      General.Enable = "Source,Sink,Media,Socket";
    };
#    hardware.pulseaudio.configFile = pkgs.writeText "default.pa" ''
#      load-module module-bluetooth-policy
#      load-module module-bluetooth-discover
#    '';
  };
}
