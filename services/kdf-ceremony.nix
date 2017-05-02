{config, lib, pkgs, ...}:

let party-site = pkgs.stdenv.mkDerivation {
  name = "party-site";
  src = /home/edanaher/ceremony-site;

  buildInputs = [pkgs. jekyll ];

  buildPhase = "
    jekyll build -d $out
  ";

  installPhase = "echo";
};
in
{
  config = lib.mkIf (config.host.name == "kdfsh") {
    services.nginx.virtualHosts = {
      "realsite.kellyandevan.party" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            root = party-site;
          };
        };
      };
    };
  };
}
