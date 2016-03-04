#!/bin/bash

# 安装vsftpd 脚本
#
VSFTP_CONF_DIR=/etc/vsftpd
PAM_CONF_DIR=/etc/pam.d

rpm -q vsftpd &>/dev/null  && echo "vsftpd 已经安装过了" && exit 2

PRE_INSTALL() {
	useradd vsftpd -s /sbin/nologin 
	useradd overlord -s /sbin/nologin
	yum -y install vsftpd pam-devel db4*
}

CONF_FTP() {
	mv $VSFTP_CONF_DIR/vsftpd.conf $VSFTP_CONF_DIR/vsftpd.conf.bak
	cat >> $VSFTP_CONF_DIR/vsftpd.conf <<EOF
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
anon_upload_enable=NO
anon_mkdir_write_enable=NO
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
chown_uploads=NO
xferlog_file=/var/log/vsftpd.log
xferlog_std_format=YES
idle_session_timeout=600
data_connection_timeout=120
nopriv_user=vsftpd
async_abor_enable=YES
ascii_upload_enable=YES
ascii_download_enable=YES
chroot_local_user=YES
chroot_list_enable=NO
ls_recurse_enable=NO
listen=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
guest_enable=YES
guest_username=overlord
virtual_use_local_privs=YES
user_config_dir=/etc/vsftpd/vconf
EOF
	touch /var/log/vsftpd.log && chown vsftpd.vsftpd /var/log/vsftpd.log && mkdir $VSFTP_CONF_DIR/vconf/
	touch $VSFTP_CONF_DIR/virtusers 
	cat >>$VSFTP_CONF_DIR/virtusers <<EOF
9188ftp
YTMzY2U1MTcwMDg4NjYyYjhlY2NlMzk4MTc0MDRkNzIgIC0K
ftp9188
YTgyMTUzMzlmNzJhNmY3ODE5NDViNjM1MTYzZjZlODQgIC0K
EOF
	db_load -T -t hash -f $VSFTP_CONF_DIR/virtusers $VSFTP_CONF_DIR/virtusers.db
}

PAM_CONF() {
	mv $PAM_CONF_DIR/vsftpd $PAM_CONF_DIR/vsftpd.bak && cat >$PAM_CONF_DIR/vsftpd <<EOF
#%PAM-1.0
auth    sufficient      /lib64/security/pam_userdb.so     db=/etc/vsftpd/virtusers
account sufficient      /lib64/security/pam_userdb.so     db=/etc/vsftpd/virtusers
EOF
}

VIRUSER_CONF() {
	while true;do
    	   read -p  "请输入FTP根路径:"  FTP_ROOT 
	   if mkdir -p $FTP_ROOT &>/dev/null || [ -d $FTP_ROOT ];then
		chown -R overlord.overlord $FTP_ROOT
		break
	   else
		echo "你输入的路径不正确，请重新输入。"
	   fi
	done
	cat >$VSFTP_CONF_DIR/vconf/vconf.tmp <<EOF
local_root=$FTP_ROOT
#指定虚拟用户的具体主路径。
anonymous_enable=NO
#设定不允许匿名用户访问。
write_enable=YES
#设定允许写操作。
local_umask=022
#设定上传文件权限掩码。
anon_upload_enable=NO
#设定不允许匿名用户上传。
anon_mkdir_write_enable=NO
#设定不允许匿名用户建立目录。
idle_session_timeout=600
#设定空闲连接超时时间。
data_connection_timeout=120
#设定单次连续传输最大时间。
max_clients=10
#设定并发客户端访问个数。
max_per_ip=5
#设定单个客户端的最大线程数，这个配置主要来照顾Flashget、迅雷等多线程下载软件。
local_max_rate=5000000
#设定该用户的最大传输速率，单位b/s。
chroot_local_user=NO
EOF
	cp $VSFTP_CONF_DIR/vconf/vconf.tmp $VSFTP_CONF_DIR/vconf/9188ftp
	cp $VSFTP_CONF_DIR/vconf/vconf.tmp $VSFTP_CONF_DIR/vconf/ftp9188
}

PRE_INSTALL
CONF_FTP
PAM_CONF
VIRUSER_CONF
db_load -T -t hash -f $VSFTP_CONF_DIR/virtusers $VSFTP_CONF_DIR/virtusers.db
service vsftpd start && service vsftpd restart && \
echo -e "安装vsftp成功！用户名密码：\n9188ftp\n
YTMzY2U1MTcwMDg4NjYyYjhlY2NlMzk4MTc0MDRkNzIgIC0K\n
ftp9188\n
YTgyMTUzMzlmNzJhNmY3ODE5NDViNjM1MTYzZjZlODQgIC0K\n
"
