{config, lib, pkgs, ...}:

let
  ctfwsinthepark = with pkgs.stdenv; mkDerivation rec {
    name = "ctfwsinthepark-${version}";
    version = "f616464";

    src = pkgs.fetchFromGitHub {
      owner = "edanaher";
      repo = "ctfwsinthepark";
      rev = version;
      sha256 = "152mvnmzc9dnd2cfgbiiks995dnz8sq2zd3czwgd5ain13fmqbvw";

    };

    buildPhase = ''
    '';

    installPhase = ''
      mkdir -p $out/
      cp -r * $out/
    '';
  };
in
{
  config = lib.mkIf config.host.ctfwsinthepark.enable {
    services.nginx.virtualHosts = {
      "www.ctfwsinthepark.com" = {
        locations."/".root = ctfwsinthepark;
        enableACME = true;
        forceSSL = true;
      };
      "ctfwsinthepark.com" = {
        globalRedirect = "www.ctfwsinthepark.com";
      }
    };
  };

  options = {
    host.ctfwsinthepark.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable ctfwsinthepark web site
      '';
    };
  };
}
