{config, lib, pkgs, ...}:

let robots-none-txt = pkgs.writeText "robots-none.txt"
  ''
    User-agent: *
    Disallow: /
  '';
  randomtoby = import /home/edanaher/randomtoby { inherit pkgs; } ;
  randomtobyPort = "8082";
in
{
  config = lib.mkIf config.host.randomtoby.enable {
    systemd.services.randomtoby = {
      description = "Random toby image server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${randomtoby}/bin/toby -p ${randomtobyPort}";
        Restart = "always";
        RestartSec = "10s";
        StartLimitInterval = "1min";
      };
    };

    services.nginx.virtualHosts = {
      "kellyandevan.party".globalRedirect = "www.kellyandevan.party";
      "www.kellyandevan.party" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/robots.txt" = {
            extraConfig = ''alias ${robots-none-txt};'';
          };
          "/imgs" = {
            root = "${randomtoby}/static";
          };
          "/css" = {
            root = "${randomtoby}/static";
          };
          "/" = {
            proxyPass = "http://localhost:${randomtobyPort}";
          };
        };
      };
    };
  };
  options = {
    host.randomtoby.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable randomtoby service.
      '';
    };
  };
}
