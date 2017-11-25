{config, lib, pkgs, ...}:

let angell-path = "/var/www/angell-classes";
    update-script = pkgs.copyPathToStore ./angell-classes.sh;
    update-path = pkgs.copyPathToStore ./angell;
    python = pkgs.python3.withPackages (ps: [ ps.docopt] );
    update-wrapper = pkgs.writeScriptBin "angell-classes-wrapper" ''
      #!/bin/sh
      mkdir -p ${angell-path}/raw
      mkdir -p /var/run/angell-classes
      ${update-script} > ${angell-path}/old.html.tmp
      mv ${angell-path}/old.html.tmp ${angell-path}/old.html

      now=`date -Iseconds`
      cd ${update-path}
      ${python}/bin/python generate.py -o ${angell-path}/new-$now.html -r ${angell-path}/raw/$now
      ln -sf ${angell-path}/new-$now.html ${angell-path}/index.html
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
