{config, lib, pkgs, ...}:

let
  secrets = import ../secrets.nix;
  mach-nix = import (builtins.fetchGit {
    url = "https://github.com/DavHau/mach-nix";
    ref = "refs/tags/3.5.0";
  }) {
    # optionally bring your own nixpkgs
    # pkgs = import <nixpkgs> {};

    # optionally specify the python version
    # python = "python38";

    # optionally update pypi data revision from https://github.com/DavHau/pypi-deps-db
    pypiDataRev = "2a2d29624d6d0531dc1064ac40f9a36561fcc7b7";
    pypiDataSha256 = "0lzlj6pw1hhj5qhyqziw9qm6srib95bhzm7qr79xfc5srxgrszca";
    #pypiDataRev = "41d5d964f46ed2e93ac2cbc7ac2dbbdc99407f97";
    #pypiDataSha256 = "1bsyq4svnnjln3qkm6way71cv28nbfvywkn9y84ahyifgv2cv8ip";
  };

  apache-superset-config = pkgs.writeTextDir "superset_config.py" ''
    SECRET_KEY = "${secrets.babybuddy.django-secret}"
    ALLOWED_HOSTS = ["localhost"]
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql_psycopg2",
            "NAME": "superset",
            "USER": "superset",
        }
    }
    SQLALCHEMY_DATABASE_URI = 'postgres://superset@/superset'
  '';                         
                         
  requirements = ''
    backoff>=1.8.0
    bleach<4.0.0,>=3.0.2
    cachelib<0.5,>=0.4.1
    celery<6.0.0,>=5.2.2
    click>=8.0.3
    colorama
    croniter>=0.3.28
    cron-descriptor
    cryptography>=3.3.2
    deprecation<2.2.0,>=2.1.0
    flask<2.2.0,>=2.0.0
    flask-appbuilder<5.0.0,>=4.1.3
    flask-caching>=1.10.0
    flask-compress
    flask-talisman
    flask-migrate
    flask-wtf
    func_timeout
    gevent>=1.4
    geopy
    graphlib-backport
    gunicorn>=20.1.0
    hashids<2,>=1.3.1
    holidays==0.10.3
    humanize
    isodate
    markdown>=3.0
    msgpack<1.1,>=1.0.0
    numpy==1.22.1
    pandas<1.4,>=1.3.0
    parsedatetime
    pgsanity
    polyline
    psycopg2
    pyparsing<4,>=3.0.6
    python-dateutil
    python-dotenv
    python-geohash
    pyarrow<6.0,>=5.0.0
    pyyaml>=5.4
    PyJWT<3.0,>=2.4.0
    redis
    selenium>=3.141.0
    simplejson>=3.15.0
    slackclient==2.5.0
    sqlalchemy!=1.3.21,<1.4,>=1.3.16
    sqlalchemy-utils<0.38,>=0.37.8
    sqlparse==0.3.0
    tabulate==0.8.9
    typing-extensions<4,>=3.10
    werkzeug==2.0.2
    wtforms-json
  '';
  apache-superset = mach-nix.buildPythonPackage {
    src = "https://files.pythonhosted.org/packages/e4/81/4e056edf84833a386e871ed5b5f1f818b1276dc8084973f3e38b7adafb74/apache-superset-2.0.0.tar.gz";
    inherit requirements;
  };
  apache-superset-python = mach-nix.mkPython {
    inherit requirements;
  };
in
{
  config = lib.mkIf config.host.superset.enable {
    services.nginx.enable = true;

    users.users.superset = {
      isSystemUser = true;
      group = "superset";
      createHome = true;
      home = "/home/superset";
    };
    users.groups.superset = {};

    systemd.services.superset = {
      description = "daemon for superset";
      after = [ "network.target" "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = { PYTHONPATH = apache-superset-config; };
      serviceConfig = {
        ExecStart = ''${apache-superset-python}/bin/gunicorn -w 3 -k gevent --worker-connections 1000 --timeout 120 -b 0.0.0.0:8124 --limit-request-line 0 --limit-request-field_size 0 "superset.app:create_app()"'';
        Restart = "always";
        RestartSec = "10s";
        PermissionsStartOnly = "true"; # Run postgres setup as root
        StartLimitIntervalSec = 60;
        User = "superset";
        WorkingDirectory = "${apache-superset}/lib/python3.9/site-packages/";
      };

      preStart = ''
        ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/createuser superset || true
        ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/createdb superset -O superset || true
        cd superset
        ${pkgs.sudo}/bin/sudo -u superset ${apache-superset}/bin/superset db upgrade
        '';
    };


    services.nginx.virtualHosts = {
      "superset" = {
        enableACME = false;
        forceSSL = false;
        locations."/".proxyPass = "http://localhost:8124";
      };

      "superset.local" = {
        enableACME = false;
        forceSSL = false;
        locations."/".proxyPass = "http://localhost:8124";
      };
    };

    services.postgresql.enable = true;
  };


  options = {
    host.superset.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable superset service
      '';
    };
  };

}
