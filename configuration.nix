# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  udev-keyboard-autoplug = (import scripts/udev-keyboard-autoplug.nix);
  acpid-script = (import scripts/acpid-script.nix);
  custom-firmware = (import firmware/default.nix);
  fvwm_gestures = pkgs.fvwm.override { gestures = true; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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
  services.udev.packages = [ udev-keyboard-autoplug ];
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
    udev-keyboard-autoplug
    acpid-script
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.synaptics.enable = true;
  # Uses a generic driver instead of the synaptics one; not as nice.
  #services.xserver.multitouch.enable = true;

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

  security.sudo.configFile= ''
    edanaher ALL=(ALL) NOPASSWD: /home/edanaher/bin/bin/_set_brightness.sh
    edanaher ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/rfkill
  '';


  time.timeZone = "America/New_York";

  # hardware.firmware = [ custom-firmware ];
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.bluetooth.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", ATTRS{idVendor}=="06cb", ATTRS{idProduct}=="2819", RUN+="${udev-keyboard-autoplug}/bin/udev-keyboard-autoplug.sh"
  '';

  services.acpid.enable = true;
  services.acpid.lidEventCommands = "${acpid-script}/bin/acpid-script.sh";
  services.logind.extraConfig = "HandleLidSwitch=ignore";

  fileSystems."/boot" =
  {
    device = "/dev/sda1";
    fsType = "vfat";
  };

  services.tlp.enable = true;
  services.tlp.extraConfig = ''
    RESTORE_DEVICE_STATE_ON_STARTUP=1
  '';

  #nix.nixPath = [ "/home/edanaher" "nixos-config=/etc/nixos/configuration.nix" ];

}
