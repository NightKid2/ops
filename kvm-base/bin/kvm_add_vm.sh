#!/bin/bash
# 该脚本用于自动分配ip地址，并创建kvm虚拟机。
# 分配IP地址，依赖于nmap扫描局域网端，并从中选取未使用IP地址。
set -e
SYS_KVMIMG_DIR=/data/kvm_img
SYS_REMOTE_IMGURL=http://download.gs.9188.com/iso/Base-Img.tar.gz
SYS_LOCAL_NETINTERFACE=`ls /etc/sysconfig/network-scripts/ |grep ifcfg-e |head -1  |sed s/ifcfg-//g`
NET_POOL=`ip addr |grep -A 3 '\<br0:' |awk -F'.'  '/inet\>/{print $3}'`

if [ $# -ne 3 ] ;then
  echo -e "Usage : $0 VM_CPU VM_MEM(Gb) [ centos6|centos7 ]\nExample : $0 2 4 centos7 " && exit 5
fi 

function GET_VM_IP() {
  mkdir -pv $SYS_KVMIMG_DIR/base/ip_pool/
  UNUSED_IP_LIST=$SYS_KVMIMG_DIR/base/ip_pool/unused_ip.list
  USED_IP_LIST=$SYS_KVMIMG_DIR/base/ip_pool/used_ip.list
  :> $UNUSED_IP_LIST
  :> $USED_IP_LIST

  for i in {19..253} ;do echo 192.168.$NET_POOL.$i >>$UNUSED_IP_LIST ;done
  nmap -n -sP -PI -PT 192.168.$NET_POOL.0/24 |awk '/^Nmap/{print $5}' |grep 192.168 > $USED_IP_LIST
  for m in `cat ${USED_IP_LIST}`;do sed -i "/$m/d"  $UNUSED_IP_LIST ;done
}

GET_VM_IP

#VM_NET_IP=`tail -1 $SYS_KVMIMG_DIR/base/ip_pool/unused_ip.list`
VM_NET_IP=$(head -$((`echo $RANDOM`%`cat $SYS_KVMIMG_DIR/base/ip_pool/unused_ip.list |wc -l`)) $SYS_KVMIMG_DIR/base/ip_pool/unused_ip.list |tail -1)


VM_VCPU=$1
VM_MEM_NOW=$(($2*1024*1024))
VM_VERSION=`echo $3 |tr A-Z a-z`
VM_NAME=$VM_VERSION-$VM_NET_IP
VM_UUID=`uuidgen`
VM_MACHINE=`qemu-kvm -machine ? |grep default |awk '{print $1}'`
VM_DISK_PATH=$SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.qcow2
VM_NET_MAC=52:54:00:b0:0$NET_POOL:`echo $VM_NET_IP |awk -F'.' '{print $4}' |xargs printf %x`
VM_NET_MAC2=52:54:00:b1:0$NET_POOL:`echo $VM_NET_IP |awk -F'.' '{print $4}' |xargs printf %x`
VM_NET_GATEWAY=`echo $VM_NET_IP |awk -F'.' '{print $1"."$2"."$3"."1}'`

function CONFIG_TEMPLATE() {
  mkdir $SYS_KVMIMG_DIR/$VM_NET_IP && cp $SYS_KVMIMG_DIR/base/$VM_VERSION-BASE.qcow2 $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.qcow2 && cp $SYS_KVMIMG_DIR/base/template.xml $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml && chown -R qemu:qemu $SYS_KVMIMG_DIR/$VM_NET_IP/
  sed -i "s/%VM_NAME%/$VM_NAME/g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
  sed -i "s/%VM_UUID%/$VM_UUID/g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
  sed -i "s/%VM_MEM_NOW%/$VM_MEM_NOW/g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
  sed -i "s/%VM_VCPU%/$VM_VCPU/g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
  sed -i "s/%VM_MACHINE%/$VM_MACHINE/g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
  sed -i "s@%VM_DISK_PATH%@$VM_DISK_PATH@g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
  sed -i "s@%VM_NET_MAC%@$VM_NET_MAC@g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
  sed -i "s@%VM_NET_MAC2%@$VM_NET_MAC2@g"  $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml
}

function PUT_IP_IN() {
  if [ $VM_VERSION = 'centos6'  ];then
	VM_NET_CONFIG=eth0
  else 
        VM_NET_CONFIG=`virt-ls -a $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.qcow2 /etc/sysconfig/network-scripts/ |awk -F'-' '/ifcfg-e/{print $2}'`
  fi

  cat <<EOF >> $SYS_KVMIMG_DIR/$VM_NET_IP/ifcfg-$VM_NET_CONFIG
TYPE=Ethernet
BOOTPROTO=static
DEVICE=$VM_NET_CONFIG
ONBOOT=yes  
IPADDR=$VM_NET_IP
NETMASK=255.255.255.0
GATEWAY=$VM_NET_GATEWAY
DNS1=114.114.114.114
EOF

 virt-copy-in -a $VM_DISK_PATH $SYS_KVMIMG_DIR/$VM_NET_IP/ifcfg-$VM_NET_CONFIG  /etc/sysconfig/network-scripts/

}

function START_VM() {
  virsh define $SYS_KVMIMG_DIR/$VM_NET_IP/${VM_NAME}.xml && virsh start $VM_NAME && echo -e "\nVM IPADDRESS:   $VM_NET_IP" && virsh dominfo $VM_NAME 

}

CONFIG_TEMPLATE
PUT_IP_IN
START_VM

