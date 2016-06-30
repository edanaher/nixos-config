with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "acpid-script";
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp ${./acpid-script.sh} $out/bin/acpid-script.sh
  '';
}
