{ config, lib , ...}:

{ 
  config = lib.mkMerge [{
      networking.nat.enable = true;
      networking.nat.internalInterfaces = ["ve-+"];
      networking.nat.externalInterface = "wlp9s0";

      virtualisation.docker.enable = true;
      virtualisation.docker.storageDriver = "btrfs";
    }
    (lib.mkIf config.host.virtualbox.enable {
      virtualisation.virtualbox.host.enable = true;
    })
  ];

  options.host.virtualbox = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable virtualbox";
    };
  };
}
