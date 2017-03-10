{config, lib, pkgs, ...}:

let robots-none-txt = pkgs.writeText "robots-none.txt"
  ''
    User-agent: *
    Disallow: /
  '';
in
{
  config = lib.mkIf (config.host.name == "kdfsh") {
    services.nginx.enable = true;

    services.nginx.recommendedOptimisation = true;
    services.nginx.recommendedTlsSettings = true;
    services.nginx.recommendedGzipSettings = true;
    services.nginx.recommendedProxySettings = true;
 
    services.nginx.virtualHosts = {
      "forum.kellyandevan.party" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/robots.txt" = {
            extraConfig = ''alias ${robots-none-txt};'';
          };
          "/" = {
            proxyPass = http://unix:/var/discourse/shared/standalone/nginx.http.sock:;
          };
        };
      };
      "*.kdf.sh" = {
        locations = {
          "/" = {
            proxyPass = http://localhost:8081;
            extraConfig = ''
              proxy_set_header X-Kdf-Real-Ip $proxy_add_x_forwarded_for;
            '';
          };
        };
      };
    };
  };
}
