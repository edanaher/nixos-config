{config, lib, pkgs, ...}:


let kdf-web = import /home/edanaher/kdf/web { inherit pkgs; } ;
    kdf-dns = import /home/edanaher/kdf/dns { inherit pkgs; } ;
in
{
  config = lib.mkIf (config.host.name == "kdfsh") {
    systemd.services.kdf-web = {
      description = "kdf dynamic web services";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${kdf-web}/bin/kdf-web -p 8081";
        Restart = "always";
        RestartSec = "10s";
        StartLimitInterval = "1min";
      };
    };

    systemd.services.kdf-dns = {
      description = "kdf dynamic dns service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${kdf-dns}/bin/kdf-dns";
        Restart = "always";
        RestartSec = "10s";
        StartLimitInterval = "1min";
      };
    };
  };
}
