{ config, lib, pkgs, ... }:

let
  acpid-script = import ../scripts/acpid-script.nix;
in
{
  imports = [
    ./_client.nix
  ];

  config = {
    services.acpid.enable = true;
    services.acpid.lidEventCommands = "${acpid-script}/bin/acpid-script.sh";
    services.logind.extraConfig = ''
      HandleLidSwitch=ignore
      HandlePowerKey=ignore
    '';

    services.tlp.enable = true;
    services.tlp.extraConfig = ''
      RESTORE_DEVICE_STATE_ON_STARTUP=1
    '';

    security.sudo.extraConfig = ''
      edanaher ALL=(ALL) NOPASSWD: /home/edanaher/bin/bin/_set_brightness.sh
      edanaher ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/rfkill
    '';
  };
}
