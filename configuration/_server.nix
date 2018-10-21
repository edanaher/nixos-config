{ config, lib, pkgs, ... }:

{
  config = {
    host.xserver.enable = false;
    host.pulseaudio.enable = false;
    host.virtualbox.enable = false;
    host.server-overlays.enable = true;
    environment.noXlibs = true;
    host.exim.class = "server";
  };
}
