#!/bin/sh

### Set Variables ###################

C_DIR=`pwd`
DATE_A=`date +"%Y%m%d-%H%M"`
export ESXNAME=`hostname -s`

#####################################

### SSH Set ###
echo "### Set SSH ###"
/etc/init.d/SSH status | grep started > /dev/null
if [ $? -eq 0 ];then
        esxcli system settings advanced set -o /UserVars/SuppressShellWarning -i 1
        echo "### SSH Service Alert Config ###"
else
        echo "### SSH Not Started ###"
fi

if [ -e /etc/ssh/sshd_config ];then
        cp -p /etc/ssh/sshd_config ${TF_DIR}/sshd_config_org_${DATE_A}
        sed -ie 's/PasswordAuthentication no/#PasswordAuthentication no/' /etc/ssh/sshd_config
        echo "### sshd config ###"
        cp -p /etc/ssh/sshd_config ${TC_DIR}/sshd_config
	/etc/init.d/SSH restart
else
        echo "### SSH Config Not Exist ###"
fi

## SLP Config ###
echo "### SLP Config ###"
esxcli network firewall ruleset set -r CIMSLP -e 1
chkconfig slpd on
/etc/init.d/slpd start
/etc/init.d/sfcbd-watchdog restart

### powermon.conf ###
#echo "### powermon.conf ###"
#cp ${C_DIR}/config_files/powermon6.conf /etc/.
#PMONMD5=`md5sum /etc/powermon6.conf |awk '{print $1}'`
#if [ ${PMONMD5} = 9fafa03dc46fbf0cc222e06abfc5ba23 ];then
#	echo "### OK md5sum check /etc/powermon6.conf ###"
#	chmod 644 /etc/powermon6.conf
#	chown root:root /etc/powermon6.conf
#else 
#	echo "### !!! NG md5sum check /etc/powermon6.conf !!! ###"
#fi

### END ###
sync;sync

echo "### $0 Shell END ###"
