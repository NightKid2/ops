#!/bin/bash
#
REPO_DIR=/etc/yum.repos.d
curl http://222.73.244.170:8000/zabbix/163.repo >$REPO_DIR/163.repo
yum -y update && yum -y groupinstall "Desktop" && yum -y groupinstall "X Window System"
