#!/bin/sh

usage=$(df -h $DISK | grep -o '[0-9]*%' | sed 's/%//' | xargs echo -n)
if [[ $usage -ge $USAGE ]]; then
  echo "Disk $DISK usage is $usage (over $USAGE)"
  exim systemd@edanaher.net <<EOF
From: chileh@edanaher.net
To: systemd@edanaher.net
Subject: Chileh $DISK is ${usage}% (over $USAGE)

$(df -h $DISK)
EOF
  runq
else
  echo "Disk $DISK usage is $usage (under $USAGE)"
fi
