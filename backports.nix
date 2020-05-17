{ config, lib, pkgs, ... }:

{
  config = {
    nixpkgs.overlays = lib.optional config.host.server-overlays.enable (self: super:
    {
    #  prosody = super.prosody.overrideAttrs (oldAttrs: rec {
    #   version = "0.9.12";
    #   name = "prosody-${version}";
    #   src = pkgs.fetchurl {
    #     url = "http://prosody.im/downloads/source/${name}.tar.gz";
    #     sha256 = "139yxqpinajl32ryrybvilh54ddb1q6s0ajjhlcs4a0rnwia6n8s";
    #   };
    #  });
    });
  };

  options = {
    host.server-overlays = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable overlays for servers";
      };
    };
  };

}

