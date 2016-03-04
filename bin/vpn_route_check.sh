#!/bin/bash
#
set -e
while true; do
  if ip route |grep '192.168.83.0/24' &>/dev/null ;then
    sleep 5
  else
    sleep 1
    ip route add 192.168.83.0/24 dev ppp0
  fi
done
