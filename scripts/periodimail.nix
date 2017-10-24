{ config, lib, pkgs, ... }:

let periodimail = pkgs.writeScript "periodimail" ''
  #!/bin/sh
  unit=''${2//\//_}
  mkdir -p /tmp/.periodimail
  MARKFILE=/tmp/.periodimail/$unit
  if [ -f $MARKFILE ]; then
    echo File exists for $unit
    if [[ $((`stat -c %Y $MARKFILE` + $1)) -lt `date +%s` ]]; then
      echo Removing stale file $unit
      rm $MARKFILE
    fi
  fi
  if [ ! -f $MARKFILE ]; then
    echo Mailing for $unit
    touch $MARKFILE
    exim systemd@edanaher.net <<EOF
  From: chileh@edanaher.net
  To: systemd@edanaher.net
  Subject: Chileh unit '$2' failed
  
  $(journalctl -u $2 -n 10)
  EOF
  fi
  echo Finished $unit
'';
  serviceForInterval = interval: {
    name = "periodimail-${builtins.toString interval}@";
    value = {
      description = "Send e-mail on unit failure, but only every ${builtins.toString interval} seconds";
      path = with pkgs; [ systemd exim ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = "${periodimail} ${builtins.toString interval} %I";
      };
    };
  };
in
{
  options = {
    services.periodimail.intervals =
      lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [];
        description = "Intervals to run periodimail on (in seconds)";
      };
  };

  config = {
    systemd.services = lib.listToAttrs (map serviceForInterval config.services.periodimail.intervals);
  };
}
