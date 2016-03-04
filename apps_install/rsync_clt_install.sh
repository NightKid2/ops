#!/bin/bash
#
if [ ! -f /tmp/rsyncd.passwd ];then
	touch /tmp/rsyncd.passwd
	echo '9188niu800' >>/tmp/rsyncd.passwd
	chmod 600 /tmp/rsyncd.passwd
fi
rsync -vrtopg  --exclude=*.log --exclude=export --exclude=logs --exclude=app.back --exclude=oracle tom@115.182.16.88::qianyi /opt --password-file=/tmp/rsyncd.passwd
