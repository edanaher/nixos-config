{config, lib, pkgs, ...}:

let utils = import ../utils.nix;
    secrets = import ../secrets.nix;
    angell-config = {
      angell-password = secrets.angell.password;
      web-path = "/var/www/angell-classes/";
      template-path = "/var/run/angell-classes";
      mail-host = "127.0.0.1";
    };
    angell-packages-build = pkgs.fetchFromGitHub {
      owner = "edanaher";
      repo = "angell-class-monitor";
      rev = "cc7292c2f3827d91b842fe8891746068ea641656";
      sha256 = "1l6554h9vlyx1wqni4dmxpzv60xq5x4081bb38vnl3bc1g4n0hql";
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
      local rsvpsite rsvpsite md5
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
