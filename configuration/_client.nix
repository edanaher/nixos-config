{ config, lib, pkgs, ... }:

{
  config = {
    programs.command-not-found.enable = true;
    time.timeZone = "America/New_York";
    host.exim.class = "client";
    environment.systemPackages = [ pkgs.firejail ];
#    security.wrappers = {
#      firejail.source = "${pkgs.firejail}/bin/firejail";
#    };
  };
}
