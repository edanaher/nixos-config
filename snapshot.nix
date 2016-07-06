{ config, lib, pkgs, ... }:

{
  services.fcron.enable = true;
  services.fcron.systab = ''
    0 7 * * * /mnt/snapshots/do.sh
    37 1 * * * { umount /mnt/snapshots && mount /mnt/snapshots; } >/dev/null 2>&1
  '';
}
