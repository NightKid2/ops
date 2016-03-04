#!/bin/bash
#
JDK_PKG=jdk-7u79-linux-x64.tar.gz
JDKDIR_NAME=jdk1.7.0_79
rpm -q wget || yum -y install wget 
wget http://222.73.244.170:8000/$JDK_PKG -O /tmp/$JDK_PKG && cd /tmp && tar xf $JDK_PKG -C /data/ && ln -sv /data/$JDKDIR_NAME /opt/jdk 

grep JAVA_HOME /etc/profile || echo -e 'JAVA_HOME=/opt/jdk \nPATH=$PATH:$JAVA_HOME/bin \nexport JAVA_HOME PATH ' >>/etc/profile
source /etc/profile 
if java -version &>/dev/null ;then
	echo "OK"
else
	echo "JDK is not install right!"
fi


