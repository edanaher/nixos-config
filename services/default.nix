{ ... }:

{
  imports = [
    ./kdf-discourse.nix
    ./kdf-nginx.nix
    ./kdf-parts.nix
    ./dovecot.nix
    ./gritonputty.nix
    ./iodine.nix
    ./prosody.nix
  ];
}
