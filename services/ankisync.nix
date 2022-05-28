{config, lib, pkgs, ...}:

let
  anki-port = 27701;
  anki-rundir = "/var/lib/ankisync";
  anki-server = with pkgs.pythonPackages; buildPythonPackage rec {
    pname = "AnkiServer";
    version = "2.0.6";

    # https://github.com/dsnopek/anki-sync-server/issues/47
    patches = [ ./anki-sync-server.patch.txt ./anki.patch.txt ];

    postPatch = ''
      substituteInPlace ankiserverctl.py \
        --replace 'SERVERCONFIG = "production.ini"' 'SERVERCONFIG = "${config-file}"' \
        --replace 'AUTHDBPATH = "auth.db"' 'AUTHDBPATH = "${anki-rundir}/auth.db"' \
        --replace 'COLLECTIONPATH = "collections/"' 'COLLECTIONPATH = "${anki-rundir}/collections/"'
    '';
    src = fetchPypi {
      inherit pname version;
      sha256 = "1vidlnplm936ivlll1jw3zymi3fxvkbz8zz4gpdykaswhg95x62s";
    };

    checkInputs = [ mock ];

    propagatedBuildInputs = [ PasteDeploy pasteScript sqlalchemy webob ];

    # We need to pass these through to pyramid, so use an environement variable, I guess.
    makeWrapperArgs = [ "--set PYTHONPATH $out/anki-bundled:$out/${python.sitePackages}:${sqlalchemy}/${python.sitePackages}:${webob}/${python.sitePackages}" ];

    meta = {
      description = "A personal Anki sync server (custom AnkiWeb replacement)";
      homepage = https://github.com/dsnopek/anki-sync-server;
      #license = stdenv.licenses.agpl3;
    };
  };
  config-file = pkgs.writeText "anki-sync.conf" ''
      [server:main]
      use = egg:AnkiServer#server
      host = 127.0.0.1
      port = ${toString anki-port}

      [filter-app:main]
      use = egg:Paste#translogger
      next = real

      [app:real]
      use = egg:Paste#urlmap
      / = rest_app
      /msync = sync_app
      /sync = sync_app

      [app:rest_app]
      use = egg:AnkiServer#rest_app
      data_root = ${anki-rundir}/collections
      allowed_hosts = 127.0.0.1
      ;logging.config_file = logging.conf

      [app:sync_app]
      use = egg:AnkiServer#sync_app
      data_root = ${anki-rundir}/collections
      base_url = /sync/
      base_media_url = /msync/
      session_db_path = ${anki-rundir}/session.db
      auth_db_path = ${anki-rundir}/auth.db
    '';
in
{
  config = lib.mkIf config.host.ankisync.enable {
    services.nginx.virtualHosts = {
      "ankisync.kdf.sh" = {
        enableACME = true;
        addSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:${toString anki-port}";
            extraConfig = "client_max_body_size 64M;";
          };
        };
      };
    };

    systemd.services.anki-sync = {
      description = "daemon for anki-sync service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = { TZ = "America/Los_Angeles"; };
      serviceConfig = {
        ExecStart = "${anki-server}/bin/ankiserverctl.py debug ${config-file}";
        Restart = "always";
        RestartSec = "10s";
        StartLimitInterval = "1min";
        User = "ankisync";
      };
    };

    users.users.ankisync = {
      description = "User to run the anki-sync service";
    };
  };
  options = {
    host.ankisync.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable anki-sync service
      '';
    };
  };
}
