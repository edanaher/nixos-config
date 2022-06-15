{config, lib, pkgs, ...}:

let
  secrets = import ../../secrets.nix;
  mach-nix = import (builtins.fetchGit {
    url = "https://github.com/DavHau/mach-nix";
    ref = "refs/tags/3.4.0";
  }) { python = "python39"; };
babybuddy-config = pkgs.writeText "babybuddy-config" ''
from .base import *

# Production settings
# See babybuddy.settings.base for additional settings information.

SECRET_KEY = "${secrets.babybuddy.django-secret}"

ALLOWED_HOSTS = ["localhost", "baby.edanaher.net"]

# Database
# https://docs.djangoproject.com/en/4.0/ref/settings/#databases

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql_psycopg2",
        "NAME": "babybuddy",
        "USER": "babybuddy",
    }
}

# Media files
# https://docs.djangoproject.com/en/4.0/topics/files/

MEDIA_ROOT = "/home/babybuddy/media"

# Security
# After setting up SSL, uncomment the settings below for enhanced security of
# application cookies.
#
# See https://docs.djangoproject.com/en/4.0/topics/http/sessions/#settings
# See https://docs.djangoproject.com/en/4.0/ref/csrf/#settings

# SESSION_COOKIE_SECURE = True
# CSRF_COOKIE_SECURE = True
#TODO: Disable this.
#CSRF_TRUSTED_ORIGINS = ["http://localhost:8089"]

#TODO: Disable this.
#DEBUG=True

'';
requirements = ''
  asgiref
  boto3
  botocore
  defusedxml
  diff-match-patch
  dj-database-url
  django
  django-appconf
  django-axes
  django-filter
  django-imagekit
  django-import-export
  django-ipware
  django-storages
  django-taggit
  django-widget-tweaks
  djangorestframework
  et-xmlfile
  faker
  gunicorn
  jmespath
  markuppy
  odfpy
  openpyxl
  pilkit
  pillow
  plotly
  psycopg2-binary
  python-dateutil
  python-dotenv
  pytz
  pyyaml
  s3transfer
  setuptools
  six
  sqlparse
  tablib[html,ods,xls,xlsx,yaml]
  tenacity
  uritemplate
  urllib3
  whitenoise
  xlrd
  xlwt
'';
babybuddy = pkgs.stdenv.mkDerivation rec {
  name = "babybuddy-${version}";
  version = "v1.10.2";

  src = pkgs.fetchFromGitHub {
    owner = "babybuddy";
    repo = "babybuddy";
    rev = version;
    sha256 = "uAEUcJIOofJXD/cN+ICS052+aEwEAGbkNPYYYiY4xAM=";
  };

  buildPhase = ''
  '';

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
    cp ${babybuddy-config} $out/babybuddy/settings/production.py
  '';

  buildInputs = [ ];
};

babybuddy-python = mach-nix.mkPython { inherit requirements; };
# babybuddy-python = pkgs.python39.withPackages (p: with p; [ gunicorn django python-dotenv django-axes ]);
in
{
  imports = [ ./backup.nix ];
  config = lib.mkIf config.host.babybuddy.enable {
    services.nginx.enable = true;

    users.users.babybuddy = {
      isSystemUser = true;
      group = "babybuddy";
      createHome = true;
      home = "/home/babybuddy";
    };
    users.groups.babybuddy = {};

    systemd.services.babybuddy = {
      description = "daemon for babybuddy";
      after = [ "network.target" "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = { DJANGO_SETTINGS_MODULE = "babybuddy.settings.production"; };
      serviceConfig = {
        ExecStart = "${babybuddy-python}/bin/gunicorn babybuddy.wsgi:application --timeout 30 --log-file -";
        Restart = "always";
        RestartSec = "10s";
        StartLimitInterval = "1min";
        PermissionsStartOnly = "true"; # Run postgres setup as root
        User = "babybuddy";
        WorkingDirectory = "${babybuddy}";
      };

      preStart = ''
        ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/createuser babybuddy || true
        ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/createdb babybuddy -O babybuddy || true
        ${pkgs.sudo}/bin/sudo -u babybuddy DJANGO_SETTINGS_MODULE=babybuddy.settings.production ${babybuddy-python}/bin/python manage.py migrate
        ${pkgs.sudo}/bin/sudo -u babybuddy DJANGO_SETTINGS_MODULE=babybuddy.settings.production ${babybuddy-python}/bin/python manage.py createcachetable
        '';
    };


    services.nginx.virtualHosts = {
      "baby.edanaher.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:8000";
      };
    };

    services.postgresql.enable = true;
  };


  options = {
    host.babybuddy.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable babybuddy service
      '';
    };
  };

}
