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

    buildInputs = with pkgs; [ urweb openssl icu ];

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
      "willcaltrainsucktoday.kdf.sh" = {
        serverAliases = [ "willcaltrainsucktoday.com" "www.willcaltrainsucktoday.com" ];
        locations."/".proxyPass = "http://localhost:8083";
        onlySSL = true;
        sslCertificate = "/var/lib/acme/kdf.sh/fullchain.pem";
        sslCertificateKey = "/var/lib/acme/kdf.sh/key.pem";
        extraConfig = ''
          listen 80;
          listen [::]:80;
        '' ;

      };
    };

    users.users.willcaltrainsucktoday = {
      isSystemUser = true;
      description = "User to run the willcaltrainsucktoday daemon";
    };

    systemd.services.willcaltrainsucktoday = {
      description = "daemon for willcaltrainsucktoday single page site";
      after = [ "network.target" "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = { TZ = "America/New_York"; };
      serviceConfig = {
        ExecStart = "${caltrain}/bin/willcaltrainsucktoday -p 8083";
        Restart = "always";
        RestartSec = "10s";
        StartLimitInterval = "1min";
        PermissionsStartOnly = "true"; # Run postgres setup as root
        User = "willcaltrainsucktoday";
      };

      preStart = ''
        ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/createuser willcaltrainsucktoday || true
        ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/createdb willcaltrainsucktoday -O willcaltrainsucktoday || true
        ${pkgs.sudo}/bin/sudo -u willcaltrainsucktoday ${pkgs.postgresql}/bin/psql willcaltrainsucktoday < ${caltrain}/etc/db.sql || true
        ${pkgs.sudo}/bin/sudo -u willcaltrainsucktoday ${ruby-env}/bin/bundle exec ${caltrain}/etc/data/import_giants.rb ${caltrain}/etc/data/giants-2017.csv
        ${pkgs.sudo}/bin/sudo -u willcaltrainsucktoday ${ruby-env}/bin/bundle exec ${caltrain}/etc/data/import_sharks.rb ${caltrain}/etc/data/sharks-2016.csv
        '';
    };

    services.postgresql.enable = true;
    # Handled in angell-classes
    #services.postgresql.authentication = ''
    #  local all all peer
    #'';
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
