{config, lib, pkgs, ...}:

let
  secrets = import ../secrets.nix;
  lwt = pkgs.stdenv.mkDerivation {
    name = "learing-with-texts-1.6.1";
		src = pkgs.fetchzip {
			url = https://downloads.sourceforge.net/project/lwt/lwt_v_1_6_1.zip;
      sha256 = "11yzddwbz7mdvky4ynmp5r3qqb2p1mwb1624qs97n96msh8flnif";
      stripRoot = false;
		};

  buildPhase = "echo";

  installPhase = ''
    mkdir -p $out
    cp -ax * $out
    mv $out/connect_xampp.inc.php $out/connect.inc.php
  '';
  };
in
{
  config = lib.mkIf config.host.lwt.enable {
    services.mysql.enable = true;
    services.mysql.package = pkgs.mysql;
    services.phpfpm.pools.lwt = {
      listen = "/var/run/lwt-php.sock";
      extraConfig = ''
        user = nobody
        pm = dynamic
        pm.max_children = 75
        pm.start_servers = 3
        pm.min_spare_servers = 2
        pm.max_spare_servers = 5
        pm.max_requests = 500
      '';
    };
		services.nginx.virtualHosts = {
      "lwt.edanaher.net" = {
        basicAuth = { lwt = secrets.lwt.password; };
        locations = {
          "/" = {
          index = "index.php";
            root = lwt;
          };
          "~ \.php$" = {
            root = lwt;
            extraConfig = ''
              fastcgi_param GATEWAY_INTERFACE CGI/1.1;
              fastcgi_param SERVER_SOFTWARE nginx;
              fastcgi_param QUERY_STRING $query_string;
              fastcgi_param REQUEST_METHOD $request_method;
              fastcgi_param CONTENT_TYPE $content_type;
              fastcgi_param CONTENT_LENGTH $content_length;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              fastcgi_param REQUEST_URI $request_uri;
              fastcgi_index index.php;
              fastcgi_pass unix:${config.services.phpfpm.pools.lwt.listen};
            '';
          };
        };
      };
		};
  };
  options = {
    host.lwt.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable learning with text (lwt) web service
      '';
    };
  };
}
