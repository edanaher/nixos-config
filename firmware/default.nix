with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "custom-firmware";
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/lib/firmware
    cp -R ${./iwlwifi-7265-12.ucode} $out/lib/firmware/
  '';
}
