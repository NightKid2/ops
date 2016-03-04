#!/bin/bash
#
#
LOG_DIR=/data/log/nginx/access
LOG_LST=`ls $LOG_DIR |grep -v bak`
# BAK_DIR=/data/log/nginx/bak
# LOG_LST=`cd $LOG_DIR && ls |grep huishuaka`

[ -d $LOG_DIR/bak ] || mkdir -pv $LOG_DIR/bak 
rpm -q bzip2 || yum -y install bzip2

for i in $LOG_LST ;do
   mv $LOG_DIR/$i $LOG_DIR/bak/$i 
done

sleep 2 && /usr/sbin/nginx -s reopen

for i in $LOG_LST ;do
   tar -jcf $LOG_DIR/bak/`date +%Y%m%d`-$i.tgz $LOG_DIR/bak/$i && rm -f $LOG_DIR/bak/$i
done

