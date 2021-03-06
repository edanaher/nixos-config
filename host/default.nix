{config, lib, pkgs, ... }:

with lib;

let
  cfg = config.host;
in
{
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
    mkMerge [ efi-boot bios-boot ];

}
