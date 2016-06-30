with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "udev-keyboard-autoplug";
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp ${./udev-keyboard-autoplug.sh} $out/bin/udev-keyboard-autoplug.sh
    #mkdir -p $out/etc/udev/rules.d
    #cp ${./udev-keyboard-autoplug.udev} $out/etc/udev/rules.d/99-udev-keyboard-autoplug.rules
  '';
}
