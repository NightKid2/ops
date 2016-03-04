#!/bin/bash
# auto install zabbix_agent 2.4.5
ZBX_PRX=zbx-proxy.tar.gz
ZBX_PRX_DIR=zbx-proxy
CFG_DIR=/etc/zabbix
DTA_DIR=/data/sqlite
rpm -q wget || yum -y install wget 
rpm -q sqlite || yum -y install sqlite 

cd /tmp && wget http://222.73.244.170:8000/zabbix/$ZBX_PRX && tar xf $ZBX_PRX && cd $ZBX_PRX_DIR && yum -y install fping* zabbix-proxy-2* zabbix-proxy-sqlite* zxbbix-2*
if [ $? -eq 0 ];then
	mkdir -pv $DTA_DIR && touch $DTA_DIR/zbx_prx.db
	chown -R zabbix:zabbix $DTA_DIR
	sqlite3 $DTA_DIR/zbx_prx.db < /usr/share/doc/zabbix-proxy-sqlite3-2.4.5/create/schema.sql
	
	sed -i s/^#\ ProxyMode=0/ProxyMode=0/g $CFG_DIR/zabbix_proxy.conf
	sed -i s/^Server=.*/Server=58.246.4.210/g $CFG_DIR/zabbix_proxy.conf
	sed -i s/^Hostname=.*/Hostname=$HOSTNAME/g $CFG_DIR/zabbix_proxy.conf
	sed -i 's/^DBName=.*/DBName=\/data\/sqlite\/zbx_prx.db/g' $CFG_DIR/zabbix_proxy.conf
	sed -i s/^DBUser=/#DBName=/g $CFG_DIR/zabbix_proxy.conf
	sed -i s/^DBSocket=/#DBSocket=/g $CFG_DIR/zabbix_proxy.conf
	service zabbix-proxy start && service zabbix-proxy restart && chkconfig zabbix-proxy on
else
	echo "zabbix proxy is not installed right!"
fi
#sed s///g /etc/zabbix/zabbix_agentd.conf
