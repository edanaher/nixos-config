{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./backports.nix
      ./host
      ./doyha-backups.nix
      ./containers.nix
      ./pulseaudio
      ./services
      ./xserver.nix
    ];

  boot.kernelParams = lib.optional (config.host.class != "server")
      "resume=${(builtins.head config.swapDevices).device}";

  networking.hostName = config.host.name; # Define your hostname.
  networking.wireless.enable = config.host.class != "server";  # Enables wireless.

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
    binutils
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.mosh.enable = true;

  programs.ssh.startAgent = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  programs.bash.enableCompletion = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.edanaher = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "audio" "docker" "wheel" "input" ];
  };

  networking.extraHosts = ''
    71.19.155.118 gahlpo
  '';

  networking.firewall.enable = true;

  #nix.nixPath = [ "/home/edanaher" "nixos-config=/etc/nixos/configuration.nix" ];

  boot.tmpOnTmpfs = true;

  security.wrappers = {
    mount.source = "${pkgs.utillinux}/bin/mount";
    umount.source = "${pkgs.utillinux}/bin/umount";
  };

  nix.useSandbox = true;
  #nix.daemonIOSchedPriority = 3;


  security.acme.email = "ssl@edanaher.net";
  security.acme.acceptTerms = true;

  boot.kernel.sysctl."vm.swappiness" = 1;
  system.stateVersion = "18.09";
}
