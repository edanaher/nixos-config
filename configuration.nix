# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  fvwm_gestures = pkgs.fvwm.override { gestures = config.host.touchscreen; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration
      ./exim.nix
      ./host
      ./hostname.nix
      ./snapshot.nix
      ./pulseaudio
    ];

  boot.kernelPackages = pkgs.linuxPackages_4_9;

  networking.hostName = config.host.name; # Define your hostname.
  networking.wireless.enable = true;  # Enables wirelessr

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };


  environment.systemPackages = with pkgs; [
    wget
    vim
    hdparm
    fvwm_gestures
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";

  programs.bash.enableCompletion = true;

  services.xserver.desktopManager.default = "fvwm";
  services.xserver.desktopManager.session =
    [ { manage = "desktop";
        name = "fvwm";
        start = ''
          export PATH=$PATH:/home/edanaher/bin/bin
          xmodmap ~/.Xmodmap
          ${fvwm_gestures}/bin/fvwm &
          waitPID=$!
        '';
      }
    ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.edanaher = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "audio" "docker" "wheel" ];
  };

  time.timeZone = "America/New_York";

  networking.extraHosts = ''
    #216.218.223.91 gahlpo
    71.19.155.118 gahlpo
    '';
  networking.firewall.allowedUDPPortRanges = [
    { from = 60000; to = 61000; }
  ];
  networking.firewall.allowedTCPPortRanges = [
    { from = 5900; to = 5920; }
    { from = 24800; to = 24800; }
  ];

  # NAT for containers
  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "wlp2s0";

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";

  boot.tmpOnTmpfs = true;

  security.setuidPrograms = [ "mount" "umount" ];

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  virtualisation.virtualbox.host.enable = true;

  nix.useSandbox = true;
}

