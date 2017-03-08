{config, lib, pkgs, ...}:

{
  config = lib.mkIf (config.host.name == "kdfsh") {
    services.nginx.enable = true;

    services.nginx.recommendedOptimisation = true;
 
    services.nginx.virtualHosts = {
      "forum.kellyandevan.party" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = http://unix:/var/discourse/shared/standalone/nginx.http.sock:;
            extraConfig = ''
              proxy_set_header Host $http_host;
              proxy_http_version 1.1;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };
      };
      "*.kdf.sh" = {
        locations = {
          "/" = {
            proxyPass = http://localhost:8081;
            extraConfig = ''
              proxy_set_header Host $http_host;
              proxy_set_header X-Kdf-Real-Ip $proxy_add_x_forwarded_for;
              proxy_http_version 1.1;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };
      };
    };
  };
}
