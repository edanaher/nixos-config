# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  udev-keyboard-autoplug = (import scripts/udev-keyboard-autoplug.nix);
  acpid-script = (import scripts/acpid-script.nix);
  custom-firmware = (import firmware/default.nix);
  my_kernelPackages = pkgs.linuxPackages_custom {
    version = "4.6.3";
    src = pkgs.fetchurl {
      url = "mirror://kernel/linux/kernel/v4.x/linux-4.6.3.tar.xz";
      sha256 = "13188892941ea6c21d5db5a391ee73a27ef20de4cc81f14574aff0a522630967";
    };
    configfile=./kernel/customKernel.config;
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # networking.firewall.enable=false;
  networking.enableIPv6 = false;

  # Use the gummiboot efi boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = my_kernelPackages;
  #boot.kernelPackages = pkgs.linuxPackages_4_6;

  #boot.kernelModules = boot.kernelModules ++ [ "i2c_core" ];
  #boot.initrd.availableKernelModules = boot.initrd.availableKernelModules ++ [ "i2c_core" ];
  boot.kernelParams = [ "resume=/dev/sda9" ];
  # boot.kernelExtraConfig = "SND_SOC_INTEL_BROADWELL_MACH y";

  # networking.hostName = "nixos"; # Define your hostname.
  networking.hostName = "kroen"; # Define your hostname.
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
    (pkgs.fvwm.override { gestures = true; })
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
	  ${pkgs.fvwm}/bin/fvwm &
          waitPID=$!
        '';
      } 
    ];
     
#  fonts.fontconfig.hinting.autohint = false;
#  fonts.fontconfig.hinting.style = "slight";
  fonts.fontconfig.ultimate.enable = true;
  fonts.fontconfig.ultimate.rendering = pkgs.fontconfig-ultimate.rendering.shove;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.edanaher = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "audio" ];
  };

  security.sudo.configFile= ''
    edanaher ALL=(ALL) NOPASSWD: /home/edanaher/bin/bin/_set_brightness.sh
  '';

  nix.buildCores = 4;

  time.timeZone = "America/New_York";

  # hardware.firmware = [ custom-firmware ];
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;

  swapDevices = [ { device = "/dev/sda9"; } ];
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

  #nix.nixPath = [ "/home/edanaher" "nixos-config=/etc/nixos/configuration.nix" ];
}
