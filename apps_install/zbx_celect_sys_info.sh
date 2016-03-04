#!/bin/bash
# 用于收集主机的相关信息；
# 采用 userparameter 的方式；

ZBX_CNF=/etc/zabbix/zabbix_agentd.conf
ZBX_PARA=/etc/zabbix/zabbix_agentd.d/userparameter_mysql.conf
ZBX_PARA_SYSINFO=/etc/zabbix/zabbix_agentd.d/userparameter_sysinfo.conf
COUNT=`grep "UnsafeUserParameters=" $ZBX_CNF |wc -l`
curl 
if [ $COUNT -eq 1 ];then
	sed -i 's/.*UnsafeUserParameters=0/UnsafeUserParameters=1/g' $ZBX_CNF
fi
grep "process.top" $ZBX_PARA &>/dev/null || echo 'UserParameter=process.top,ps -eo rss,pmem,pcpu,args |sort -k 3 -rn |head -3'>>$ZBX_PARA_SYSINFO

service zabbix-agent restart
