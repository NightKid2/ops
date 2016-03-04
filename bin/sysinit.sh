#!/bin/bash
# sys_init

#sys_6_only() {
sys_6_only() {
	# ä.主æ
	LOC_HOSTNAME=`ip a |awk -F'/' '/192.168/{print $1}' |awk '{print $2}'|sed 's/\./-/g' |head -1`
	ping 114.114.114.114 -c 2 &>/dev/null && sed -i "s@HOSTNAME=.*@HOSTNAME=$LOC_HOSTNAME@g" /etc/sysconfig/network
	hostname $LOC_HOSTNAME
}	

sys_7_only() {
	# ä.主æ
	hostnamectl set-hostname `ip addr |awk '/inet\>/{print $2}' |awk -F'/' '/192/{print $1}' |sed 's/192.168.//g' |sed 's/\./-/g'`
}

sys_basic() {
	yum -y install wget telnet tree lsof man ntpdate lrzsz tree vim sysstat dstat nmap
	grep ulimit /etc/profile &>/dev/null || echo "ulimit -HSn 65536" >>/etc/profile
	echo "5 * * * * /usr/sbin/ntpdate asia.pool.ntp.org &> /dev/null" >> /var/spool/cron/root && /usr/sbin/ntpdate asia.pool.ntp.org &> /dev/null 	
	grep PS1 /etc/rc.d/rc.local || echo "export PS1='\[\e[1;32m\]\u:\h \W$\[\e[m\]' ; alias grep='grep --color=auto'; alias cdnet='cd /etc/sysconfig/network-scripts/'" >>/etc/rc.d/rc.local
	
	# user command to /var/log/message
	grep PROMPT_COMMAND /etc/profile &>/dev/null || cat  <<EOF >>/etc/profile 
export PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });logger "\$(whoami)" [\$(pwd)] "\$msg"; }'
EOF

}
del_init_sh() {
     grep 'bash /root/sysinit.sh' /etc/rc.d/rc.local && sed -i '/\/root\/sysinit.sh/d' /etc/rc.d/rc.local 
}
sys_basic
if cat /etc/redhat-release |grep '6\.[0-9]' &>/dev/null ;then
	sys_6_only
else
	sys_7_only
fi

