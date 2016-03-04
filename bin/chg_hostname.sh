#!/bin/bash
#
H_NAME_FILE=/etc/sysconfig/network
IF_NAME=`ifconfig |head -1 |awk '{print $1}' |sed s/[[:digit:]]//g`
INTERFACE=myif
if echo $IF_NAME |grep em &>/dev/null ;then
	INTERFACE=em1
else
	INTERFACE=eth0
fi
IPADDR=`ifconfig $INTERFACE |grep 'inet\>' |awk '{print $2}' |awk -F: '{print $2}'`
NEW_NAME=`echo $IPADDR |sed 's/\./-/g'`
if echo $HOSTNAME |grep 'localhost.localdomain' &>/dev/null ;then
	sed -i s/^HOSTNAME=.*/HOSTNAME=$NEW_NAME/g $H_NAME_FILE && echo $NEW_NAME>/proc/sys/kernel/hostname && echo "hostname is changed to $NEW_NAME"
fi 
