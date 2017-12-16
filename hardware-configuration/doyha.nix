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

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/e9bf5566-4a48-4505-a1a2-ba54ed4e9df3";
      fsType = "btrfs";
      options = [ "subvol=@" "compress" "noatime" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/e9bf5566-4a48-4505-a1a2-ba54ed4e9df3";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B429-A22E";
      fsType = "vfat";
    };

  boot.initrd.luks.devices."btrfs".device = "/dev/disk/by-uuid/efa8285a-df23-47e6-b2e3-9fd930f5b295";
  boot.initrd.luks.devices."btrfs".preLVM = false;

  swapDevices = [ { device = "/dev/mapper/vgmain-swap"; } ];

  nix.maxJobs = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = "powersave";

  # Coffee Lake i915 is "alpha" quality?
  boot.kernelPackages = pkgs.linuxPackages_4_14;
  #boot.kernelParams = [ "i915.alpha_support" ];
}
