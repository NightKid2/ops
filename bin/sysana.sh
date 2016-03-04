#!/bin/bash
#
set -e
ROOT_BIN=/root/bin
rpm -q sysstat &>/dev/null || yum -y install sysstat
rpm -q procps &>/dev/null || yum -y install procps 
[ -f $ROOT_BIN/sysana ] && exit 3
[ -d $ROOT_BIN ] || mkdir $ROOT_BIN

cat <<EOF >>$ROOT_BIN/sysana
#!/bin/bash
set -e
[ \$# -eq 1 ] || exit 2
case "\$1" in  
# uptime
  uptime|load)
    uptime
    echo 
    ;;
# dmesg |tail
  dmesg)
    dmesg |tail
    echo
    ;;
# vmstat 1
  vmstat|vm)
    vmstat 1 10
    echo
    ;;
# mpstat -P ALL 1
  mpstat|mp)
    mpstat -P ALL 1 5
    echo   
    ;;
  
# pidstat 1
  pidstat|pid)
    pidstat 1 5
    echo 
    ;;
# iostat -xz 1
  iostat|io)
    iostat -xz 1 10
    echo 
    ;;

# free -m
  free|mem)
    free -m
    echo
    ;;
# sar -n DEV 1
  net|network)
    sar -n DEV 1 5
    echo 
    ;;

# sar -n TCP,ETCP 1
  connect|conn)
    ss -s 
    sleep 1 
    sar -n TCP,ETCP 1 10
    echo
    ;;
# top
  top|all)
    top
    ;;
# disk useage 
  df|disk)
    df -h
    echo
    lsblk -if
    ;;

  *)
   echo -e $"Usage: sysana CMD \n CMD in { uptime|load dmesg vmstat|vm mpstat|mp pidstat|pid)iostat|io free|mem net|network connect|conn top|all }"
esac
EOF

chmod +x $ROOT_BIN/sysana
