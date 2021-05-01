# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./pci-passthrough.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.autoScrub.enable = true;

  networking.hostId = "f587ff94";

  boot.kernelParams = [ "pci=noaer" "zfs.zfs_arc_max=17179869184" /*"i915.enable_fbc=0" */];
  services.xserver.videoDrivers = lib.mkForce ["intel"];
  /*services.xserver.drivers = [{
    name = "intel";
    deviceSection = ''
      Option VirtualHeads "2"
    '';
  }];*/

  fileSystems."/" =
    { device = "zfsroot/root";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "zfsroot/home";
      fsType = "zfs";
    };

  fileSystems."/home/edanaher" =
    { device = "zfsroot/home/edanaher";
      fsType = "zfs";
    };

  fileSystems."/nix/store" =
    { device = "zfsroot/nix/store";
      fsType = "zfs";
    };

  fileSystems."/build" =
    { device = "zfsroot/build";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B429-A22E";
      fsType = "vfat";
    };

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

#    fileSystems."/mnt/kelly-bak" =
#    { device = "/dev/mapper/vgvagafah-kelly--bak";
#      fsType = "ext4";
#      options = [ "nofail" "noatime" ];
#    };

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

#  boot.initrd.luks.devices."btrfs".device = "/dev/disk/by-uuid/efa8285a-df23-47e6-b2e3-9fd930f5b295";
#  boot.initrd.luks.devices."btrfs".preLVM = false;

  swapDevices = [ { device = "/dev/disk/by-id/nvme-Samsung_SSD_960_EVO_1TB_S3ETNB0J406507V-part4"; } ];

  nix.maxJobs = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = "powersave";

  boot.kernelPackages = pkgs.linuxPackages_5_2;
}
