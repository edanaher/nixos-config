# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, modulesPath, pkgs, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/xen-domU.nix"
  ];

  config = lib.mkMerge [ {
    boot.initrd.availableKernelModules = [ "xen_blkfront" ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];
    boot.loader.grub.extraPerEntryConfig = "root (hd0,4)";

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/9daaaa08-ac9c-42ee-bee2-c7807ffbabfc";
        fsType = "btrfs";
        options = [ "subvol=root" "noatime" "compress" ];
      };

    fileSystems."/home" =
      { device = "/dev/disk/by-uuid/9daaaa08-ac9c-42ee-bee2-c7807ffbabfc";
        fsType = "btrfs";
        options = [ "subvol=home" "noatime" "compress" ];
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/ad834324-780f-4b26-9db2-bbc5a1801eb0";
        fsType = "ext2";
      };

    swapDevices = [ ];

    nix.maxJobs = lib.mkDefault 1;
  }
  # xen-domU.nix wants to use grub 2; override that here.
  (lib.mkForce { boot.loader.grub.version = 1; })
  ];
}
