#!/bin/sh

### Set Variables ###################

C_DIR=`pwd`
DATE_A=`date +"%Y%m%d-%H%M"`
export ESXNAME=`hostname -s`
export ESXIVER=`esxcli system version get |grep Version |awk '{print $2}'`

### Set Directories & Files #########

T_DIR="${C_DIR}/${ESXNAME}_config"
TV_DIR="${T_DIR}/vib"
TC_DIR="${T_DIR}/conf"
CONF_D="${C_DIR}/config_files"

PT_DIR="${C_DIR}/esxi_patch_"

PTCHLST="${CONF_D}/list-esxipatch.txt"

#####################################

cd ${C_DIR}

### ESXi Mode Check ###
vim-cmd hostsvc/hostsummary |grep -i MaintenanceMode |awk '{print $3}' |grep false > /dev/null
if [ $? -eq 0 ];then
        echo "### ESXi Maintenance Mode On ###"
        vim-cmd hostsvc/maintenance_mode_enter > /dev/null 2>&1
else
        echo "### ESXi Already Maintenance Mode ###"
fi

mkdir -p ${TV_DIR}

LISTIMG=`ls ${C_DIR}/customeimage_70/`
IMGESXI=${C_DIR}/customeimage_70/${LISTIMG}

ls ${IMGESXI}
if [ $? -eq 0 ];then
        echo "### Exist ESXi 7.0 Custome Image ###"
        ### MD5SUM Check ESXi Patch ###
	case ${LISTIMG} in
		"ESXi-7.0.3-19193900-NEC-7.0-05.zip" )
			MD5ESXI=d71f5bef57c886a6f2cba31eaefb029a
			md5sum ${IMGESXI} |grep ${MD5ESXI}
                        if [ $? -eq 0 ];then
                                echo "### Checked MD5SUM  ###"
				esxcli software profile update --depot=${IMGESXI} --profile=NEC-addon_7.0.3-02 >> ${TV_DIR}/${ESXNAME}_verup70u3.txt
				if [ $? -eq 0 ];then
                                        echo "### ESXi 7.0 U3 update OK ###"
                                else
                                        echo "### !!! Can't ESXi 7.0 U3 !!! ###"
                                        exit 0
                                fi
                        else
                                echo "### !!! NOT MATCH MD5SUM !!! ###"
                                exit 0
                        fi
			;;
		* )
                	echo "### NOT RUN VerUP ###"
	                ;;
	esac
else
        echo "### !!! NOT Exist ESXi 7.0 Custome Image !!! ###"
	exit 0
fi

### END ###
sync;sync
# /bin/reboot
echo "### Plese Reboot type in [ /bin/reboot ]"
echo "### $0 Shell END ###"
