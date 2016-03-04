#!/bin/bash
#
set -e
KVM_IMG_DIR=/data/kvm_img
BASE_IMG=http://download.gs.9188.com/iso/base-img.tar.gz
LOCAL_INTERFACE=`ls /etc/sysconfig/network-scripts/ |grep ifcfg-e |head -1  |sed s/ifcfg-//g`

lsmod | grep kvm &>/dev/null && lsmod |grep -E '(kvm_intel|kvm_amd)' &>/dev/null
if [ $? -ne 0 ];then
    exit 2 && echo 'KVM mode is not loaded!'
fi

grep -E "(vmx|svm)" /proc/cpuinfo &>/dev/null
if [ $? -ne 0 ];then
    exit 3 && echo 'You computer is not SUPPORT Virtual Tech OR the VT is NOT OPEN!'
fi

ping 114.114.114.114 -c 2
if [ $? -ne 0 ];then
    exit 4 && echo 'Cannot connect to Internet,PLZ check you Network!'
fi

function GET_KVM_PACKAGES(){
    yum -y install qemu-kvm qemu-kvm-tools && ln -sv /usr/libexec/qemu-kvm /usr/bin/qemu-kvm
    yum -y install libvirt libvirt-client virt-install virt-manager virt-viewer && service libvirtd start
    yum -y install libguest* libvirt* wget tigervnc tigervnc-server bridge-utils
    # grep 192.168.1.211 /etc/hosts || echo "192.168.1.211    download.gs.9188.com" >>/etc/hosts
    mkdir -pv $KVM_IMG_DIR
    cd /tmp && wget $BASE_IMG && tar xf /tmp/base-img.tar.gz -C $KVM_IMG_DIR && chown -R qemu:qemu $KVM_IMG_DIR 
    [ -d /root/.ssh ] || mkdir /root/.ssh ; chmod  700 /root/.ssh
    cat <<EOF >>/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvO+/j4ClnVKm3naL1obNRhkdor5KCgDybTGSGwng8XY6HmX2VTb3SsZ7PmrIAU0Uico3BFT7fGozivWm2zwysfhLsnMF1n1gso5DzrgOSQbMRdZdDRucrWxN7xQqbydB3CMyEZDsD+fcuYqthQoi1BXWITHq72d88nqodAkkObgcKxRZYnEo4Ac+Z5uvGdaA5bBhzXjJa3ZSOES9MXVJOg5OCc32J4kAwwa5CyVEkWXldzJgQ6UsHi+heK8HQhM7MposLTL9CWdB4hMAQgAhHBisf+mXG0oyEmlrLT/uxHXup+G6He8Sm2Msxd9X1RLZOe3d89OwmZ9MAIdr9+5Xz root@kvm-1.40
EOF
}
function ADD_NET_BRIDGE() {
  yum -y install bridge-utils
  virsh iface-bridge $LOCAL_INTERFACE br0
} 
function PROMOTE_CAPABILITY() {
  echo cfg >> /sys/block/sda/queue/scheduler
  sysctl -w vm.nr_hugepages=
}

GET_KVM_PACKAGES
ADD_NET_BRIDGE
