{config, lib, pkgs, ...}:

let robots-none-txt = pkgs.writeText "robots-none.txt"
  ''
    User-agent: *
    Disallow: /
  '';
in
{
  config = lib.mkIf config.host.kdf-services.enable {
    services.nginx.enable = true;
    services.nginx.package = pkgs.nginx.override { modules = [ pkgs.nginxModules.echo ]; };

    services.nginx.recommendedOptimisation = true;
    services.nginx.recommendedTlsSettings = true;
    services.nginx.recommendedGzipSettings = true;
    services.nginx.recommendedProxySettings = true;

    services.nginx.commonHttpConfig = ''
      log_format extended '$remote_addr - $remote_user [$time_local] '
                      '"$request_method $scheme://$http_host$request_uri $server_protocol" $status $body_bytes_sent '
                      '"$http_referer" "$http_user_agent"';
      access_log syslog:server=unix:/dev/log extended;
      '';
      # Default format:
      #log_format main '$remote_addr - $remote_user [$time_local] '
      #                '"$request" $status $body_bytes_sent '
      #                '"$http_referer" "$http_user_agent"';
 
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
      # Generate an ACME cert for kdf.sh, but otherwise serve from kdf-web.
      "kdf.sh" = {
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = http://localhost:8081;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header Hostname $proxy_add_x_forwarded_for;
            '';
          };
        };
      };
      "echo.kdf.sh" = {
        locations = {
          "/" = {
            extraConfig = ''
              default_type text/plain;
              echo_duplicate 1 $echo_client_request_headers;
              echo "\r";
              echo_read_request_body;
              echo_request_body;
            '';
          };
        };
      };
      "www.partywiththe.party" = {
        globalRedirect = "kgb30.com";
        locations = {
          "/" = {
            #globalRedirect = "kgb30.com";
          };
        };
        };
      "partywiththe.party" = {
        globalRedirect = "kgb30.com";
        locations = {
          "/" = {
            #globalRedirect = "kgb30.com";
          };
        };
        };
      "*.kdf.sh" = {
        locations = {
          "/" = {
            proxyPass = http://localhost:8081;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Kdf-Real-Ip $proxy_add_x_forwarded_for;
            '';
          };
        };
      };
    };
  };
}
