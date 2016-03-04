#!/bin/bash
#
ARP_FILE=/tmp/arp.txt
[ -f $ARP_FILE ] &&  :>$ARP_FILE
#INTER_LIST=`cat /etc/udev/rules.d/70-persistent-net.rules |awk -F\" '/SUB/{print $14}'`
INTER_LIST=`ifconfig |grep "^[a-z]" |awk '{print $1} ' |grep -v "lo"`
for i in $INTER_LIST ; do
    if ifconfig $i |awk 'gsub(/inet addr:/,"") {print $1}' |grep "[0-9]" &>/dev/null ;then 
	INTER_MAC=`ifconfig $i |awk '/HWaddr/ {print $5}'`
	INTER_IP=`ifconfig $i |awk 'gsub(/inet addr:/,"") {print $1}'`
	echo "$INTER_IP $INTER_MAC" >>$ARP_FILE
    fi
done
#echo "  该脚本会生成 \"IP MAC\" 格式的arp数据列表，生成文件为 /tmp/arp.txt"
echo
cat $ARP_FILE
