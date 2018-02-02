{config, lib, pkgs, ...}:

let utils = import ../utils.nix;
    secrets = import ../secrets.nix;
    angell-config = {
      angell-password = secrets.angell.password;
      web-path = "/var/www/angell-classes";
      template-path = "/var/run/angell-classes";
      mail-host = "127.0.0.1";
    };
    angell-packages-build = pkgs.stdenv.mkDerivation rec {
      version = "c984813dfdcbdcfb777f036e5ebd67a9d8f0ecd7";
      name = "build-angell-monitor-${builtins.substring 0 8 version}";
      src = pkgs.fetchFromGitHub {
        owner = "edanaher";
        repo = "angell-class-monitor";
        rev = version;
        sha256 = "07lr1qfydm0iwbzsvid1jqgz1q532lcyl3k34cjizpxfb5kw8znf";
      };

      installPhase = ''
        cp -a . $out
      '';
    };
    angell-packages = import "${angell-packages-build}" { inherit pkgs; inherit (angell-config) web-path template-path mail-host angell-password; } ;
in
{
  config = lib.mkIf config.host.angell-classes.enable {
    services.nginx.appendHttpConfig = ''lua_package_path ";;${angell-packages.lua-path}";'';
    services.nginx.virtualHosts = {
      "angell.kdf.sh" = angell-packages.nginx-locations;
    };

    systemd.services.update-angell-classes = angell-packages.service;
    systemd.timers.update-angell-classes = utils.simple-timer "daily" "Scrape updates for Angell classes daily";

    users.users.angell.description = "User to run the angell-class-monitor script";

    services.postgresql.authentication = ''
      local angell angell md5
      local all all peer
    '';
  };
  options = {
    host.angell-classes.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable angell-classes site and update service.
      '';
    };
  };
}
