{config, lib, pkgs, ...}:

let
  secrets = import ../../secrets.nix;
  utils = import ../../utils.nix;
  backupScript = pkgs.writeShellScript "backup-postgres-babybuddy" ''
  export AWS_ACCESS_KEY_ID=${secrets.babybuddy.aws_access_key_id}
  export AWS_SECRET_ACCESS_KEY=${secrets.babybuddy.aws_secret_access_key}
  export AWS_DEFAULT_REGION=us-east-1

  now=$(date +%Y-%m-%dT%H-%M-%SZ)
  dir=$(date +%Y/%m/%d)
  ${pkgs.postgresql_12}/bin/pg_dump babybuddy | ${pkgs.zstd}/bin/zstd > /tmp/babybuddy-$now.sql.zstd
  ${pkgs.awscli}/bin/aws s3 cp /tmp/babybuddy-$now.sql.zstd s3://edanaher-postgres-backup/kdfsh-baby/$dir/
  #rm /tmp/babybuddy-$now.sql.zst
'';
in
{
  config = lib.mkIf config.host.babybuddy.enable {
    systemd.services.backup-postgres-babybuddy = {
      description = "Backup postgres babybuddy database";
      path = with pkgs; [ ];
      wants = [ "network-online.target" "postgresql.service" ];
      serviceConfig = {
        User = "babybuddy";
        Group = "babybuddy";
        ExecStart = "${backupScript}";
        Restart = "on-failure";
        RestartSec = "1h";
      };
    };
    systemd.timers.backup-postgres-babybuddy = utils.simple-timer "hourly" "Backup babybuddy every 6 hours";
  };

}
