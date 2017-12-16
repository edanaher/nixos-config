{ config, lib , ...}:

{ 
  config = lib.mkMerge [{
      networking.nat.enable = true;
      networking.nat.internalInterfaces = ["ve-+"];
      networking.nat.externalInterface = "wlp9s0";

      virtualisation.docker.enable = true;
      virtualisation.docker.storageDriver = "btrfs";
      networking.firewall.extraCommands = ''
        iptables -A INPUT -p tcp --dport 25 -s 10.233.1.2 -j ACCEPT
      '';
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
