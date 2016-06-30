#!/bin/sh

if [ -x /home/edanaher/bin/bin/_reset_keyboard ]; then
	nohup /home/edanaher/bin/bin/_reset_keyboard >> /tmp/deub 2>&1 &
fi
