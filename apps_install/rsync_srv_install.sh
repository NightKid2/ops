#!/bin/bash
#
rpm -q rsync || yum -y install rsync
RSYNC_CNF=/tmp/`date +%F`
mkdir $RSYNC_CNF && touch $RSYNC_CNF/{rsync.conf,rsync.passwd}

cat >>$RSYNC_CNF/rsync.conf <<EOF
uid = root
gid = root
user chroot = yes
max connections = 10
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
read only = no

[qianyi]
path = 
ignore errors
read only = yes
list = no
secrets file = $RSYNC_CNF/rsync.passwd
hosts allow = 58.246.4.210 
hosts deny = 0.0.0.0/0

[qianyi1]
path = 
ignore errors
read only = yes
list = no
secrets file = $RSYNC_CNF/rsync.passwd
hosts allow = 211.144.120.47 211.144.120.50
hosts deny = 0.0.0.0/0

[qianyi2]
path = 
ignore errors
read only = yes
list = no
secrets file = $RSYNC_CNF/rsync.passwd
hosts allow = 211.144.120.47 211.144.120.50
hosts deny = 0.0.0.0/0

[qianyi3]
path = 
ignore errors
read only = yes
list = no
secrets file = $RSYNC_CNF/rsync.passwd
hosts allow = 211.144.120.47 211.144.120.50
hosts deny = 0.0.0.0/0

[qianyi4]
path = 
ignore errors
read only = yes
list = no
secrets file = $RSYNC_CNF/rsync.passwd
hosts allow = 211.144.120.47 211.144.120.50
hosts deny = 0.0.0.0/0
EOF

echo "tom:9188niu800">>$RSYNC_CNF/rsync.passwd
chmod 600 $RSYNC_CNF/rsync.passwd
#rsync --daemon --config=$RSYNC_CNF/rsync.conf
#iptables -A INPUT  -s 211.144.120.50 -m state --state NEW -m tcp -p tcp --dport 873 -j ACCEPT
