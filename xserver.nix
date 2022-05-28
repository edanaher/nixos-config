{ config, lib, pkgs, ... }:

let
  fvwm_gestures = pkgs.fvwm; #.override { gestures = config.host.touchscreen; };
in
{
  config = lib.mkIf config.host.xserver.enable {
    services.xserver.enable = true;
    services.xserver.layout = "us";

    services.xserver.displayManager.defaultSession = "fvwm";
    services.xserver.displayManager.session =
      [ { manage = "desktop";
          name = "fvwm";
          start = ''
            export PATH=$PATH:/home/edanaher/bin/bin
            xmodmap ~/.Xmodmap
            ${fvwm_gestures}/bin/fvwm &
            /home/edanaher/.fvwm/.makeXdie &
            waitPID=$!
          '';
        }
      ];

    environment.systemPackages = with pkgs; [
      fvwm_gestures
      hsetroot
      rxvt_unicode-with-plugins
      xorg.xmodmap
      xorg.xev
    ];
  };
}
