{ config, lib , ...}:

{ 
  config = lib.mkMerge [{
      networking.nat.enable = true;
      networking.nat.internalInterfaces = ["ve-+" "tap-boogihn"];
      networking.nat.externalInterface = "wlp9s0"; # TOOO: parameterize for primary interface.

      virtualisation.docker.enable = true;
      virtualisation.docker.storageDriver = "btrfs";
      networking.firewall.extraCommands = ''
        iptables -A INPUT -p tcp --dport 25 -s 10.233.1.2 -j ACCEPT
        iptables -A INPUT -p tcp -s 192.168.199.2/28 -j ACCEPT
        iptables -A INPUT -p udp -s 192.168.199.2/28 -j ACCEPT
      '';


    }
    (lib.mkIf config.host.virtualbox.enable {
      virtualisation.virtualbox.host.enable = true;
    })
    (lib.mkIf (config.host.samba.enable) {
      services.samba.enable = true;
      services.samba.extraConfig = ''
         guest ok = yes
         guest only = yes
         valid users = edanaher
         guest account = edanaher
         force user = edanaher
         security = user

         load printers = no
         printing = bsd
         printcap name = /dev/null
         disable spoolss = yes
         acl allow execute always = true
      '';
      services.samba.shares = {
        transfer = {
          path = "/build/windows/transfer/";
          browseable = "yes";
          comment = "Share for boogihn";
          "read only" = "no";
          "valid users" = "edanaher";
          "force user" = "edanaher";
        };
        kduncan-bak = {
          path = "/mnt/kelly-bak/";
          browseable = "yes";
          comment = "Kelly's backup";
          "read only" = "no";
          "valid users" = "kduncan";
          "force user" = "kduncan";
          "fruit:appl" = "yes";
          "vfs objects" = "catia fruit streams_xattr";
        };
      };
    })
  ];

  options.host.virtualbox = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable virtualbox";
    };
  };

  options.host.samba = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable samba";
    };
  };
}
