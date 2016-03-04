#!/bin/bash
#
set -e

if [ ! -n "$1" ] ;then
    echo "请输入一个网段作为参数！" && exit 3
fi

UNUSED_IP_LIST=/data/kvm-img/base/ip_pool/unused_ip.list
USED_IP_LIST=/data/kvm-img/base/ip_pool/used_ip.list
NET_POOL=$1

for i in {2..253} ;do echo 192.168.$NET_POOL.$i >$UNUSED_IP_LIST ;done
nmap -n -sP -PI -PT 192.168.$NET_POOL.0/24 |awk '/^Nmap/{print $5}' |grep 192.168 > $USED_IP_LIST
for m in  `cat $USED_IP_LIST `;do sed -i "/$m/d"  $UNUSED_IP_LIST ;done
