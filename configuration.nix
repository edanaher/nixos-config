# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  fvwm_gestures = pkgs.fvwm.override { gestures = config.host.touchscreen; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration
      ./host
      ./hostname.nix
      ./containers.nix
      ./exim.nix
      ./pulseaudio
      ./xserver.nix
    ];

  boot.kernelParams = lib.optional (config.host.class != "server")
      "resume=${(builtins.head config.swapDevices).device}";

  networking.hostName = config.host.name; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless.

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "lat9w-16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget
    vim
    hdparm
    screen
    rxvt_unicode
    hsetroot
    binutils
    xlibs.xmodmap
    xlibs.xev
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  programs.bash.enableCompletion = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.edanaher = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "audio" "docker" "wheel" ];
  };

  networking.extraHosts = ''
    71.19.155.118 gahlpo
  '';

  networking.firewall.allowedUDPPortRanges = [
    { from = 60000; to = 61000; }  # Mosh
  ];
  networking.firewall.allowedTCPPortRanges = [
    { from = 5900; to = 5910; } # VNC
    { from = 24800; to = 24800; } # Synergy
  ];

  #nix.nixPath = [ "/home/edanaher" "nixos-config=/etc/nixos/configuration.nix" ];

  boot.tmpOnTmpfs = true;

  security.setuidPrograms = [ "mount" "umount" ];

  nix.useSandbox = true;
  nix.daemonNiceLevel = 10;
  nix.daemonIONiceLevel = 3;
}
