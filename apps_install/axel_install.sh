#!/bin/bash
AXEL_PKG=axel-2.4-1.el6.rf.x86_64.rpm
rpm -ql  wget &>/dev/null || yum -y install wget 
if [ $? -eq 0 ];then
  wget -O /tmp/$AXEL_PKG http://222.73.244.170:8000/$AXEL_PKG && rpm -ivh /tmp/$AXEL_PKG
  grep axel ~/.bashrc &>/dev/null || echo "alias wget='axel -n 10'" >>~/.bashrc
  source ~/.bashrc
fi
