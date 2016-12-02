# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./pulseaudio
    ];

  # Use the GRUB 2 boot loader.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.version = 2;
  # # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda";
  #
  # Use the gummiboot efi boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 10;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "gemedet"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
   wget
   vim
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
	  ${pkgs.fvwm}/bin/fvwm &
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

  nix.buildCores = 8;

  #networking.firewall.allowedTCPPortRanges = [
  #  { from = 5900; to = 5920; }
  #];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

  boot.tmpOnTmpfs = true;

  security.setuidPrograms = [ "mount" "umount" ];

  #virtualisation.docker.enable = true;
  #virtualisation.docker.storageDriver = "btrfs";

  #virtualisation.virtualbox.host.enable = true;

  #services.physlock.enable = true;
  #services.physlock.user = "edanaher";

  nix.useSandbox = true;
}

