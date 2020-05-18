{config, lib, pkgs, ...}:

let utils = import ../utils.nix;
    secrets = import ../secrets.nix;
    rsvp-config = {
      ceremony-rsvp-password = secrets.ceremony-rsvp.password;
    };
    ceremony-rsvp-build = pkgs.fetchFromGitHub {
      owner = "edanaher";
      repo = "ceremony-rsvp";
      rev = "c320e65b788c7271e40e74f16b7a1324502ecd26";
      sha256 = "1swkynhl1vlfys5vmibii6zvb3s80nfnrmk87ixs42wkad2m0ara";
      
    };
    rsvp = import "${ceremony-rsvp-build}" { inherit pkgs; inherit (rsvp-config) ceremony-rsvp-password; } ;
    site = rsvp.site;
in
{
  config = lib.mkIf config.host.ceremony-rsvp.enable {
    #services.nginx.appendHttpConfig = ''lua_package_path ";;${rsvp.lua-path}";'';
    services.nginx.virtualHosts = {
      "www.kellyandevan.party" = rsvp.nginx-locations;
    };

    systemd.services.init-rsvp-ceremony = rsvp.service;

    users.users.rsvpsite.description = "User to run the ceremony rsvp site";
  };
  options = {
    host.ceremony-rsvp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable ceremony rsvp site and init service.
      '';
    };
  };
}
