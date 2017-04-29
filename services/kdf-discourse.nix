{ config, lib, pkgs, ...}:

{
  config = lib.mkIf (config.host.name == "kdfsh") {
    systemd.services.party-discourse = {
      description = "Discourse docker container";
      path = with pkgs; [ docker gawk git inetutils which ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/var/discourse/launcher start app";
      };
    };
  };
}
