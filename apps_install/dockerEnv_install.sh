#!/bin/bash
# docker env install

set -e 

SYS_RELEASE=/etc/redhat-release
LOCAL_REGISTRY=192.168.1.33:5000
DOCKER_CONFIG=/etc/sysconfig/docker
DOWNLOAD_URL=http://222.73.244.170:8000
IP_LAST=`ip a |awk -F'/' '/192.168/{print $1}' |awk -F'.' '{print $4}'`
# Install docker

if cat $SYS_RELEASE |grep -E "\<7\.[0-9]" &>/dev/null ;then
    curl $DOWNLOAD_URL/zabbix/docker.repo >//etc/yum.repos.d/docker.repo && yum -y install docker-engine bridge-utils wget
    service docker start 
	# docker pull centos
else
   echo "This Script is ONLY SUPPORT CentOS7 " && exit 2
fi

# confige local registry

sed -i 's/^ExecStart/#ExecStart/g' /usr/lib/systemd/system/docker.service && sed -i "/#ExecStart/a ExecStart=/usr/bin/docker daemon -H fd:// -bip=172.16.$IP_LAST.1/24 --insecure-registry 192.168.1.33:5000 "  /usr/lib/systemd/system/docker.service

[ $? -eq 0 ] && systemctl daemon-reload && systemctl restart docker

#sed -i "s/^OPTIONS=/#OPTIONS=/g" $DOCKER_CONFIG && cat <<EOF >>$DOCKER_CONFIG
#OPTIONS='--selinux-enabled --insecure-registry $LOCAL_REGISTRY -b=br0'
#EOF

# confige local network and add pipework tools

if rpm -q docker-engine &>/dev/null ;then
	systemctl stop docker
	wget $DOWNLOAD_URL/docker/pipework/pipework -O /usr/sbin/pipework && chmod +x /usr/sbin/pipework
else 
	echo "You have not Install docker,Plz install it from beginning."

fi

# LOCAL_IP=`ip a |awk '/192.168/ {print $2}' |awk -F'/' '{print $1}'`
# cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-br0
#ip link set docker0 down && brctl delbr docker0 && brctl addbr br0 && cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-br0
#TYPE=Bridge
#BOOTPROTO=static
#DEVICE=br0
#ONBOOT=yes  
#EOF
#[ $? -eq 0 ] && grep -E '(IPADDR|NETMASK|GATEWAY|DNS)' /etc/sysconfig/network-scripts/ifcfg-eth0 >> /etc/sysconfig/network-scripts/ifcfg-br0
#[ $? -eq 0 ] && cat <<EOF >/etc/sysconfig/network-scripts/ifcfg-eth0
#TYPE=Ethernet
#DEVICE=eth0
#ONBOOT=yes
#BRIDGE=br0
#EOF
#[ $? -eq 0 ] && systemctl stop NetworkManager && systemctl restart network
# add useful tools : docker-enter
ls -al /root |grep bashrc_docker || wget $DOWNLOAD_URL/docker/bashrc_docker -O /root/.bashrc_docker 
cat <<EOF >>/root/.bashrc
[ -f ~/.bashrc_docker ] && . ~/.bashrc_docker
EOF
systemctl restart docker 
