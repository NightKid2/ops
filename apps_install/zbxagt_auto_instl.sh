#!/bin/bash
# auto install zabbix_agent 2.4.5
ZBX_AGT=zbx-agent.tar.gz
ZBX_AGT_DIR=zbx-agent
CFG_DIR=/etc/zabbix
rpm -q wget || yum -y install wget 

cd /tmp && wget http://222.73.244.170:8000/zabbix/$ZBX_AGT && tar xf $ZBX_AGT && cd $ZBX_AGT_DIR && yum -y install zabbix* && sed -i s/^Hostname=.*/Hostname=$HOSTNAME/g /etc/zabbix/zabbix_agentd.conf && sed -i s/^ServerActive=/#ServerActive=/g /etc/zabbix/zabbix_agentd.conf && chkconfig zabbix-agent on
sed -i 's/.*UnsafeUserParameters=.*/UnsafeUserParameters=1/g' /etc/zabbix/zabbix_agentd.conf && service zabbix-agent restart
