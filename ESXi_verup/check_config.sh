#!/bin/sh -x

### Set Variables ###################

C_DIR=`pwd`
DATE_A=`date +"%Y%m%d-%H%M"`
export ESXNAME=`hostname -s`

#####################################

hostname

esxcli system version get

esxcli software profile get

esxcli software vib list

esxcli network ip interface ipv4 get

esxcli network ip route ipv4 list

esxcli network ip dns server list

esxcli network ip dns search list

esxcli network ip get

ntpq -pn

esxcli system syslog config logger list |grep -C 3 "hostd.log"

esxcli system syslog config logger list |grep -C 3 "vpxa.log"

esxcli system syslog config logger list |grep -C 3 "vmkernel.log"

cat /etc/vmware/locker.conf

esxcli system settings keyboard layout get

esxcli storage filesystem list |grep swf |wc -l

esxcli storage filesystem list |grep swf |awk '{print $2}'

### END ###
sync;sync

echo "### $0 Shell END ###"
