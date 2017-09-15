# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_hcd" "usbhid" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8e74b8e7-fd92-4e62-b9b5-55782f48e064";
      fsType = "btrfs";
      options = [ "subvol=root" "compress" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/8a67afc2-ddc9-45c9-ad78-64fcf9a48898";
      fsType = "ext2";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/8e74b8e7-fd92-4e62-b9b5-55782f48e064";
      fsType = "btrfs";
      options = [ "subvol=home" "compress" "noatime" ];
    };

  /*fileSystems."/home/edanaher/extra" =
    { device = "/dev/mapper/vgtor-home--extra";
      fsType = "ext4";
      options = [ "noatime" "noexec" ];
    };*/

  fileSystems."/mnt/snapshots" =
    { device = "/dev/mapper/vgvagafah-home--snapshots";
      fsType = "btrfs";
      options = [ "compress" "noatime" "nofail" ];
    };

  fileSystems."/mnt/movies" =
    { device = "/dev/mapper/vgvagabree-movies";
      fsType = "ext4";
      options = [ "nofail" "noatime" ];
    };

  fileSystems."/mnt/old" =
    { device = "/dev/mapper/vgvagabree-old";
      fsType = "ext4";
      options = [ "nofail" "noatime" ];
    };

  fileSystems."/mnt/bak" =
    { device = "/dev/mapper/vgvagabree-bak";
      fsType = "ext4";
      options = [ "nofail" "noatime" ];
    };

  fileSystems."/mnt/external" =
    { device = "/dev/disk/by-uuid/6d5f4267-2d60-4cd6-b623-3b96793b3529";
      fsType = "btrfs";
      options = [ "noauto" "noatime" "nofail" "compress" "user" ];
    };

  fileSystems."/mnt/external-borg" =
    { device = "/dev/md/borg-bak";
      fsType = "ext4";
      options = [ "noauto" "noatime" "nofail" "user" ];
    };

  fileSystems."/mnt/snapshots-borg" =
    { device = "/dev/vgvagabree/borg-home";
      fsType = "ext4";
      options = [ "noatime" "nofail" ];
    };

  fileSystems."/mnt/data" =
    { device = "/dev/mapper/vgvagabree-data";
      fsType = "ext4";
      options = [ "noatime" "nofail" ];
    };

  fileSystems."/mnt/kobo" =
    { device = "/dev/disk/by-uuid/51A9-A1CD";
      fsType = "vfat";
      options = [ "noatime" "nofail" "noauto" "user" ];
    };


  swapDevices =
    [ { device = "/dev/sdc1"; }
    ];

  nix.maxJobs = lib.mkDefault 4;
}
