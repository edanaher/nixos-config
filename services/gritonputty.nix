{config, lib, pkgs, ...}:

let gritonputty = with pkgs.stdenv; mkDerivation rec {
  name = "gritonputty-${version}";
  version = "74db064";

  src = pkgs.fetchFromGitHub {
    owner = "edanaher";
    repo = "gritonputty";
    rev = version;
    sha256 = "16gnqsmrr7wcziq4c8hjps424frqcsh0cra2nw612i22r9g0fadz";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out/
  '';
};
in
{
  config = lib.mkIf config.host.gritonputty.enable {
    services.nginx.virtualHosts = {
      "gritonputty.kdf.sh" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            root = gritonputty;
            index = "index.html";
          };
        };
      };
    };
  };
  options = {
    host.gritonputty.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable grit-on-putty service
      '';
    };
  };
}
