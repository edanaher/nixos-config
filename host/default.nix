{config, lib, pkgs, ... }:

with lib;

let
  cfg = config.host;
  acpid-script = import ../scripts/acpid-script.nix;
in
{
  imports = [
    ./hosts.nix
  ];
  options.host = {
    name = mkOption {
      type = types.str;
      description = ''
        Host name.  Used for config.networking.hostName and to determine other
        options.
      '';
    };
    class = mkOption {
      type = types.enum [ "laptop" "desktop" "server" ];
      description = ''
        Class of machine; used to pick reasonable defaults
      '';
    };
    touchscreen = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether or not the host has a touchscreen; enables relevant features.
      '';
    };
    boot-type = mkOption {
      type = types.enum [ "bios" "efi" "xen" ];
      default = "efi";
      description = ''
        Type of boot; bios will use grub; efi will use systemd-boot/gummiboot.
      '';
    };
    pulseaudio.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether or not to use pulseaudio.
      '';
    };
    xserver.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether or not to use X.
      '';
    };
    kdf-services.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Bulk-enable the various kdf services.
      '';
    };
  };

  config =
    let
      client = mkIf (cfg.class != "server") {
        programs.command-not-found.enable = true;
        time.timeZone = "America/New_York";
        host.exim.class = "client";
        environment.systemPackages = [ pkgs.firejail ];
        security.wrappers = {
          firejail.source = "${pkgs.firejail}/bin/firejail";
        };
      };
      desktop = mkIf (cfg.class == "desktop") {
      };
      laptop = mkIf (cfg.class == "laptop") {
        services.acpid.enable = true;
        services.acpid.lidEventCommands = "${acpid-script}/bin/acpid-script.sh";
        services.logind.extraConfig = "HandleLidSwitch=ignore";

        services.tlp.enable = true;
        services.tlp.extraConfig = ''
          RESTORE_DEVICE_STATE_ON_STARTUP=1
        '';

        security.sudo.extraConfig = ''
          edanaher ALL=(ALL) NOPASSWD: /home/edanaher/bin/bin/_set_brightness.sh
          edanaher ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/rfkill
        '';
      };
      server = mkIf (cfg.class == "server") {
        host.xserver.enable = false;
        host.pulseaudio.enable = false;
        host.virtualbox.enable = false;
        host.server-overlays.enable = true;
        environment.noXlibs = true;
        host.exim.class = "server";
      };
      efi-boot = mkIf (cfg.boot-type == "efi") {
        boot.loader.systemd-boot.enable = true;
        boot.loader.timeout = 10;
        boot.loader.efi.canTouchEfiVariables = true;
      };
      bios-boot = mkIf (cfg.boot-type == "bios") {
        boot.loader.grub.enable = true;
        boot.loader.grub.version = 2;
        # TODO: How to extract /dev/sda from symlink /dev/disk/by-uuid/*?
        boot.loader.grub.device = "/dev/sda"; #config.fileSystems."/boot".device;
      };
    in
    mkMerge [ client laptop desktop server
              efi-boot bios-boot ];

}
