{config, lib, pkgs, ...}:

let robots-none-txt = pkgs.writeText "robots-none.txt"
  ''
    User-agent: *
    Disallow: /
  '';
  kdf-www-packages-build = pkgs.fetchFromGitHub {
    owner = "edanaher";
    repo = "kdf-www";
    rev = "1fc0003abc125af7a79256260a1322599c0ad368";
    sha256 = "1plbd3ik78pd8sq5zdgjshw2i5grr1mz46riny3i4dzxsbx86bwx";
  };
  kdf-www-packages = import "${kdf-www-packages-build}" { inherit pkgs; } ;
in
{
  config = lib.mkIf config.host.kdf-services.enable {
    services.nginx.enable = true;
    services.nginx.package = pkgs.nginx.override { modules = with pkgs.nginxModules; [ echo lua ]; };

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
      #"forum.kellyandevan.party" = {
      #  enableACME = true;
      #  forceSSL = true;
      #  locations = {
      #    "=/robots.txt" = {
      #      extraConfig = ''alias ${robots-none-txt};'';
      #    };
      #    "/" = {
      #      proxyPass = http://unix:/var/discourse/shared/standalone/nginx.http.sock:;
      #    };
      #  };
      #};
      # Generate an ACME cert for kdf.sh, but otherwise redirect to www.
      "kdf.sh" = {
        enableACME = true;
        globalRedirect = "www.kdf.sh";
      };
      "www.kdf.sh" = kdf-www-packages.nginx-locations // {
        enableACME = true;
        forceSSL = true;
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
        globalRedirect = "partywiththe.party";
        locations = {
          "/" = {
            #globalRedirect = "kgb30.com";
          };
        };
      };
      "partywiththe.party" = {
        locations = {
          "/" = {
            alias = "/home/edanaher/kgb30/";
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
