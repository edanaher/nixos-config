{config, lib, pkgs, ...}:

let party-site = pkgs.stdenv.mkDerivation rec {
  name = "party-site-${version}";
  version = "9e77304";

  src = pkgs.fetchFromGitHub {
    owner = "edanaher";
    repo = "ceremony-website";
    rev = version;
    sha256 = "0x24fbf5kxsmjxgi4ng9lpflgfdqq3snxwk2qa4x7jb4yv1yg24w";
  };

  buildInputs = [pkgs. jekyll ];

  buildPhase = "
    jekyll build -d $out
  ";

  installPhase = "echo";
};
in
{
  config = lib.mkIf config.host.kdf-services.enable {
    services.nginx.virtualHosts = {
      "www.kellyandevan.party" = {
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
