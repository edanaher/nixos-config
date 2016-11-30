# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "ahci" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1a51ddb0-1625-4db4-8cef-fd79894af395";
      fsType = "btrfs";
      options = [ "subvol=root" "compress" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/e53e014b-8fe5-4eb9-be4d-9c3a3f8c284a";
      fsType = "ext2";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/F49A-AC67";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/1a51ddb0-1625-4db4-8cef-fd79894af395";
      fsType = "btrfs";
      options = [ "subvol=home" "compress" "noatime" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/3b19a8af-ddc2-45ce-8545-f47d29e13e26"; }
    ];

  nix.maxJobs = lib.mkDefault 8;
}
