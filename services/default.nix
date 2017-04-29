{ ... }:

{
  imports = [
    ./kdf-discourse.nix
    ./kdf-nginx.nix
    ./kdf-parts.nix
    ./dovecot.nix
    ./gritonputty.nix
    ./randomtoby.nix
    ./iodine.nix
    ./prosody.nix
  ];
}
