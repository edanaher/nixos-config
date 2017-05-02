{ config, lib , ...}:
{ 
  config = lib.mkMerge [{
      networking.nat.enable = true;
      networking.nat.internalInterfaces = ["ve-+"];
      networking.nat.externalInterface = "wlp2s0";

      virtualisation.docker.enable = true;
      virtualisation.docker.storageDriver = "btrfs";
    }
    (lib.mkIf (config.host.name != "kdfsh") {
      virtualisation.virtualbox.host.enable = true;
    })
  ];
}
