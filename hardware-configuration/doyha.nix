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
    { device = "/dev/vgvagasehn/borg-home";
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

  nix.settings.max-jobs = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = "powersave";

  boot.kernelPackages = pkgs.linuxPackages_5_15;

    #ACTION=="add", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2303", RUN+="${
    #  pkgs.writeShellScript "setupKeyboard" ''
    #    export DISPLAY=:0
    #    export XAUTHORITY=/home/edanaher/.Xauthority
    #    ${pkgs.xorg.setxkbmap}/bin/setxkbmap us -variant altgr-intl
    #    ${pkgs.xorg.xset}/bin/xset r rate 300 34
    #  '' }"
    #
    #ACTION=="add", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5100", RUN+="${
    #  pkgs.writeShellScript "setupKeyboard" ''
    #    export DISPLAY=:0
    #    export XAUTHORITY=/home/edanaher/.Xauthority
    #    ${pkgs.xorg.setxkbmap}/bin/setxkbmap us -variant altgr-intl
    #    ${pkgs.xorg.xset}/bin/xset r rate 300 34
    #  '' }"
    #
    #ACTION=="add", ATTRS{idVendor}=="214e", ATTRS{idProduct}=="0005", RUN+="${
#       let xinput = "${pkgs.xorg.xinput}/bin/xinput"; in
#       pkgs.writeShellScript "setupSwiftpoint" ''
#         export DISPLAY=:0
#         export XAUTHORITY=/home/edanaher/.Xauthority
#         sleep 1
#         for MOUSE in `${xinput} --list | grep Swiftpoint | grep -v Z\ Keyboard | sed 's/.*id=\([0-9]*\).*/\1/'`; do
#           ${xinput} set-prop $MOUSE 'Device Accel Profile' 2
#           ${xinput} set-prop $MOUSE 'Device Accel Constant Deceleration' 1.4
#           ${xinput} set-prop $MOUSE 'Device Accel Adaptive Deceleration' 1.6
#           ${xinput} set-prop $MOUSE 'Device Accel Velocity Scaling' 0.6
#         done
#       '' }"
    #
  services.udev.extraRules = ''
    ACTION=="add", ATTRS{id/vendor}=="055a", ATTRS{id/product}=="0998", ATTRS{capabilities/ev}=="120013", ATTRS{phys}=="usb-0000:00:14.0-13/input0", SYMLINK+="input/by-id/foot-pedal-back"
#    #-%n-%k-$attr{capabilities/ev}"
    ACTION=="add", ATTRS{id/vendor}=="055a", ATTRS{id/product}=="0998", ATTRS{capabilities/ev}=="120013", ATTRS{phys}!="usb-0000:00:14.0-13/input0", SYMLINK+="input/by-id/foot-pedal-front"
    ACTION=="add", ATTRS{id/vendor}=="0991", ATTRS{id/product}=="af14", SYMLINK+="input/by-id/virtual-evmerge-device"
    ACTION=="add", ATTRS{id/vendor}=="1235", ATTRS{id/product}=="5679", ATTRS{name}=="KMonad: Feet", SYMLINK+="input/by-id/virtual-kmonad-device"
    ACTION=="add", SUBSYSTEM=="tty", ATTRS{idVendor}=="feed", ATTRS{idProduct}=="6065", ATTRS{manufacturer}=="OLKB", SYMLINK+="ttyPLANCK0"
    ACTION=="add", SUBSYSTEM=="tty", ATTRS{idVendor}=="feed", ATTRS{idProduct}=="3621", ATTRS{manufacturer}=="Noll Electronics LLC", SYMLINK+="ttyNOLL0"
    ACTION=="add", SUBSYSTEM=="tty", ATTRS{idVendor}=="feed", ATTRS{idProduct}=="6060", ATTRS{manufacturer}=="SOFT/HRUF", SYMLINK+="ttySOFTHRUF"
  '';

  services.udev.extraHwdb = ''
    ACTION=="add|change", KERNEL=="event[0-9]*", ATTRS{idVendor}=="05f3", ATTRS{idProduct}=="00ff", ENV{ID_INPUT_KEYBOARD}="1"

    # infinity foot pedal
    evdev:input:b*v05F3p00FF*
     KEYBOARD_KEY_90001=f14 #pagedown
     KEYBOARD_KEY_90002=f15 #down
     KEYBOARD_KEY_90003=f16 #pageup

    # foot switch
    #evdev:input:b*v055Ap0998*
    # KEYBOARD_KEY_7001e=3 # left
    # KEYBOARD_KEY_7001f=5 # mid
    # KEYBOARD_KEY_70020=6 # right

    # noppoo
    evdev:input:b*v0483p5100*
     KEYBOARD_KEY_70029=capslock
     KEYBOARD_KEY_700e0=esc
     KEYBOARD_KEY_70039=leftctrl
     KEYBOARD_KEY_70046=f13
  '';
}
