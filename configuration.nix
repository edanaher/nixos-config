# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  fvwm_gestures = pkgs.fvwm.override { gestures = true; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration
      ./host
      ./hostname.nix
      ./exim.nix
    ];

  # Use the gummiboot efi boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [ "resume=${(builtins.head config.swapDevices).device}" ];

  networking.hostName = config.host.name; # Define your hostname.
  networking.hostId = "65c89bd7";
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
    fvwm_gestures
#    fvwm
    screen
    rxvt_unicode
    hsetroot
    binutils
    imagemagick
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
    extraGroups = [ "audio" ];
  };

  time.timeZone = "America/New_York";

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.bluetooth.enable = true;

  services.tlp.enable = true;
  services.tlp.extraConfig = ''
    RESTORE_DEVICE_STATE_ON_STARTUP=1
  '';

  #nix.nixPath = [ "/home/edanaher" "nixos-config=/etc/nixos/configuration.nix" ];

}
