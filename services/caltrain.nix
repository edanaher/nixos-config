{config, lib, pkgs, ...}:

let
  ruby-env = pkgs.bundlerEnv {
    name = "caltrain-gems";
    inherit (pkgs) ruby;

    gemfile = "${caltrain.src}/data/Gemfile";
    lockfile = "${caltrain.src}/data/Gemfile.lock";
    gemset = "${caltrain.src}/data/gemset.nix";
  };
  caltrain = with pkgs.stdenv; mkDerivation rec {
    name = "willcaltrainsucktoday-${version}";
    version = "7b421c1c";

    src = pkgs.fetchFromGitHub {
      owner = "edanaher";
      repo = "willcaltrainsucktoday";
      rev = version;
      sha256 = "1r63j1158klc7llhwx3qjrmbyhwfpvmln2zr5xifdzs44jbbcym9";
    };

    buildInputs = with pkgs; [ urweb openssl ];

    buildPhase = ''
      urweb willcaltrainsucktoday
    '';

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/etc
      cp willcaltrainsucktoday $out/bin
      cp db.sql $out/etc
      cp -r data $out/etc
    '';
  };
in
{
  config = lib.mkIf config.host.caltrain.enable {
    services.nginx.virtualHosts = {
      "willcaltrainsucktoday.com".globalRedirect = "www.willcaltrainsucktoday.com";
      "www.willcaltrainsucktoday.com" = {
        locations."/".proxyPass = "http://localhost:8083";
      };
      "willcaltrainsucktoday.kdf.sh" = {
        locations."/".proxyPass = "http://localhost:8083";
      };
    };

    users.users.willcaltrainsucktoday = {
      description = "User to run the willcaltrainsucktoday daemon";
    };

    systemd.services.willcaltrainsucktoday = {
      description = "daemon for willcaltrainsucktoday single page site";
      after = [ "network.target" "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = { TZ = "America/Los_Angeles"; };
      serviceConfig = {
        ExecStart = "${caltrain}/bin/willcaltrainsucktoday -p 8083";
        Restart = "always";
        RestartSec = "10s";
        StartLimitInterval = "1min";
        PermissionsStartOnly = "true"; # Run postgres setup as root
        User = "willcaltrainsucktoday";
      };

      preStart = ''
        ${pkgs.postgresql}/bin/createuser willcaltrainsucktoday || true
        ${pkgs.postgresql}/bin/createdb willcaltrainsucktoday -O willcaltrainsucktoday || true
        ${pkgs.sudo}/bin/sudo -u willcaltrainsucktoday ${pkgs.postgresql}/bin/psql willcaltrainsucktoday < ${caltrain}/etc/db.sql || true
        ${ruby-env}/bin/bundle exec ${caltrain}/etc/data/import_giants.rb ${caltrain}/etc/data/giants-2017.csv
        ${ruby-env}/bin/bundle exec ${caltrain}/etc/data/import_sharks.rb ${caltrain}/etc/data/sharks-2016.csv
        '';
    };

    services.postgresql.enable = true;
    services.postgresql.authentication = ''
      local all all peer
    '';
  };

  options = {
    host.caltrain.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable willcaltrainsucktoday service
      '';
    };
  };
}
