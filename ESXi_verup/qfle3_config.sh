#!/bin/sh

### Set Variables ###################

C_DIR=`pwd`
DATE_A=`date +"%Y%m%d-%H%M"`
export ESXNAME=`hostname -s`

#####################################

echo "### qfle3_driver_conf ###"

echo "esxcli device driver list |grep qfle3"
esxcli device driver list |grep qfle3
if [ $? -ne 0 ];then
	echo "### qfle3 device driver not use ###"
	exit 0
fi

vmkload_mod -l | grep qfle3i
if [ $? -eq 0 ];then
	echo "### qfle3i Enabled config false ###"
	esxcli system module set --enabled=false --module=qfle3i
else
	echo "### qfle3i Disabled ###"
fi

vmkload_mod -l | grep qfle3f
if [ $? -eq 0 ];then
        echo "### qfle3f Enabled config false ###"
        esxcli system module set --enabled=false --module=qfle3f
else
        echo "### qfle3f Disabled ###"
fi

### END ###
sync;sync
# /bin/reboot
echo "### Plese Reboot type in [ /bin/reboot ]"
echo "### $0 Shell END ###"
