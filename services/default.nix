{ ... }:

{
  imports = [
    ./kdf-discourse.nix
    ./kdf-nginx.nix
    ./kdf-parts.nix
    ./kdf-ceremony.nix
    ./dovecot.nix
    ./gritonputty.nix
    ./randomtoby.nix
    ./caltrain.nix
    ./iodine.nix
    ./prosody.nix
    ./lwt.nix
    ./angell-classes.nix
    ./nowaytopreventthis.nix
    ./disk-mon.nix
    ./ctfwsinthepark.nix
  ];
}
