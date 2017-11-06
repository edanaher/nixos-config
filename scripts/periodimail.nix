{ pkgs }:

let periodimail-script = pkgs.writeScriptBin "periodimail" ''
  #!/bin/sh
  unit=''${2//\//_}
  mkdir -p /tmp/.periodimail
  if [[ $UID == 0 ]]; then
    chmod a+rwxt /tmp/.periodimail
    chown root /tmp/.periodimail
  fi
  MARKFILE=/tmp/.periodimail/$unit

  echo Running $3 on $1/$2
  $3
  status=$?

  if [[ $status -eq 0 ]]; then
    if [ -f $MARKFILE ]; then
      echo Removing and mailing now-successful file $unit
      rm $MARKFILE
      /run/wrappers/bin/exim systemd@edanaher.net <<EOF
  From: chileh@edanaher.net
  To: systemd@edanaher.net
  Subject: Chileh unit '$2' succeeded

  $(journalctl -u $2 -n 10)
  EOF
    fi
  else
    if [ -f $MARKFILE ]; then
      echo File exists for $unit
      if [[ $((`stat -c %Y $MARKFILE` + $1)) -lt `date +%s` ]]; then
        echo Removing stale file $unit
        rm $MARKFILE
      fi
    fi
    if [ ! -f $MARKFILE ]; then
      echo Mailing failure for $unit
      touch $MARKFILE
      /run/wrappers/bin/exim systemd@edanaher.net <<EOF
  From: chileh@edanaher.net
  To: systemd@edanaher.net
  Subject: Chileh unit '$2' failed
  
  $(journalctl -u $2 -n 10)
  EOF
    fi
  fi
  echo Finished $unit
  exit $status
'';
in
{
  wrap = { interval, service, script}:
    "${periodimail-script}/bin/periodimail ${builtins.toString interval} ${service} ${script}";
}
