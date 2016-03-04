#!/bin/bash
devtype=`dmidecode -s system-product-name`
serinum=`dmidecode -s system-serial-number`
location=`curl ip.cn `
ipmacaddr=`ifconfig |grep '^[a-k=m-z]' -A 1 |awk '/HWaddr/{print $1,$5}/addr:/{print $2}' |awk 'NR%2{printf $0" ";next}1' |grep  'addr' |sed s/addr://g`
#ipmacaddr=`ifconfig |grep '^[a-k=m-z]' -A 1 |awk '/HWaddr/{print $1}/addr:/{print $2}' |awk 'NR%2{printf $0" ";next}1' |grep  'addr' |sed s/addr://g`
disk=`lsblk |grep '^[a-z]' |grep 'disk' |awk '{print $1,$4}'`
mem=`free -g |awk '/Mem/{print $2}'`
cpunum=`lscpu  |awk '/^CPU\(s\)/{print $2}'`
osver=`cat /etc/redhat-release`
kernel=`uname -a`
hostname=`hostname`
#app=`ls /opt |egrep -v '(www|backup|log|tar|gz|bz|rpm|zip|bin|export|data)'`

echo $devtype,$serinum,$location,$ipmacaddr,$disk,$mem,$cpunum,$osver,$kernel,$hostname,$app 
#echo $ipmacaddr
#echo $devtype 
#echo $serinum
#echo $disk
#echo $mem


