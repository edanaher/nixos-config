{config, lib, pkgs, ...}:

let gritonputty = with pkgs.stdenv; mkDerivation rec {
  name = "gritonputty-${version}";
  version = "2b5d9899";

  src = pkgs.fetchFromGitHub {
    owner = "edanaher";
    repo = "gritonputty";
    rev = version;
    sha256 = "04vlxxnh3vrgb8f6cw7633i41ngx1jqqp4pfv19849zv6d7g1v8p";

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
