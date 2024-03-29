# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "btrfs" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.supportedFilesystems = [ "exfat" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/acfbe5c4-50a7-4e63-a5d3-daad2b5221d6";
      fsType = "btrfs";
      options = [ "subvol=root" "compress" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/acfbe5c4-50a7-4e63-a5d3-daad2b5221d6";
      fsType = "btrfs";
      options = [ "subvol=home" "compress" ];
    };

  fileSystems."/boot" =
  {
    device = "/dev/sda1";
    fsType = "vfat";
  };

  swapDevices =
    [ { device = "/dev/sda7"; }
    ];

  nix.settings.max-jobs = 4;
}
