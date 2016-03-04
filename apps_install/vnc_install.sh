#!/bin/bash
#
VNC_CFG=/etc/sysconfig/vncservers
USR_CFG=~/.vnc/xstartup
yum -y groupinstall xfce && yum -y install  tigervnc-server

if [$? -eq 0 ]; then
	echo 'VNCSERVERS="1:root"' >> $VNC_CFG 
	echo 'VNCSERVERARGS[1]="-geometry 1024x768"' >> $VNC_CFG
	vncpasswd <<EOF
9188.com
9188.com
EOF
	mv $USR_CFG{,.bak}
	echo -e '#!/bin/bash \n /usr/bin/startxfce4' >> $USR_CFG && chmod +x $USR_CFG
	service vncserver start
	chkconfig vncserver on
fi
