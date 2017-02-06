#!/bin/sh

export XAUTHORITY=/home/edanaher/.Xauthority
export PATH=$PATH:/run/current-system/sw/bin/
export DISPLAY=:0
STATE=`cat /proc/acpi/button/lid/LID0/state | xargs echo -n`
if [ "${STATE#* }" == "closed" ]; then
  xset dpms force off >> /tmp/deug-acpid 2>&1
else
  xset dpms force on >> /tmp/deug-acpid 2>&1
fi
