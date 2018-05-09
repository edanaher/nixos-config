{config, lib, pkgs, ...}:

let gritonputty = with pkgs.stdenv; mkDerivation rec {
  name = "gritonputty-${version}";
  version = "ee4f8252";

  src = pkgs.fetchFromGitHub {
    owner = "edanaher";
    repo = "gritonputty";
    rev = version;
    sha256 = "1vxnj3ll1iv1ax460cb7jf13qs9bc7xllflm4cmpkw0gs3msrxzs";
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
