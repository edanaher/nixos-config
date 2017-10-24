{config, lib, pkgs, ...}:

let angell-path = "/var/run/angell-classes";
    update-script = pkgs.copyPathToStore ./angell-classes.sh;
    update-wrapper = pkgs.writeScriptBin "angell-classes-wrapper" ''
      #!/bin/sh
      mkdir -p /var/run/angell-classes
      ${update-script} > ${angell-path}/index.html.tmp
      mv ${angell-path}/index.html.tmp ${angell-path}/index.html
    '';
    utils = import ../utils.nix;
in
{
  config = lib.mkIf config.host.angell-classes.enable {
    services.nginx.virtualHosts = {
      "angell.kdf.sh" = {
        locations."/" = {
          root = angell-path;
          index = "index.html";
        };
      };
    };

    systemd.services.update-angell-classes = {
      description = "Scrape updates for Angell classes";
      path = with pkgs; [ curl ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        User = "root";
        Group = "root";
        ExecStart = "${update-wrapper}/bin/angell-classes-wrapper";
        Restart = "on-failure";
        RestartSec = "4h";
      };
    };

    systemd.timers.update-angell-classes = utils.simple-timer "daily" "Scrape updates for Angell classes daily";
  };
  options = {
    host.angell-classes.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable angell-classes site and update service.
      '';
    };
  };
}
