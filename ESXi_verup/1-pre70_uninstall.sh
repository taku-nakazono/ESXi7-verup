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

### ESXi Version Check ###
esxcli system version get |grep "6.7.0" > /dev/null
if [ $? -eq 0 ];then
	echo "### ESXi Version 6.7 Check OK ###"
else
	echo "### ESXi Version is not 6.7 ###"
	exit 1
fi

### Verup Pre PP Uninstall ###
## NEC SPS Uninstall ##
esxcli software vib list |grep -i nec_satp_sps
if [ $? -eq 0 ];then
	esxcli storage nmp satp rule remove --satp NEC_SATP_SPS --vendor NEC --model "DISK ARRAY" --boot
	if [ $? -eq 0 ];then
		esxcli storage nmp satp rule list |grep -i nec
		if [ $? -eq 1 ];then
			echo "### NEC_SATP_SPS removed rule  ###"
			esxcli software vib remove -n nec_satp_sps > /dev/null
			if [ $? -eq 0 ];then
				echo "### NEC_SATP_SPS Uninstalled  ###"
			else
				echo "### NEC_SATP_SPS NOT uninstall ###"
				exit 1
			fi
		else
			echo "### NEC_SATP_SPS not removed rule ###"
			exit 1
		fi
	else
		echo "### NEC_SATP_SPS NOT removed  rule ###"
		exit 1
	fi
else
	echo "### List not NEC SATP SPS vib  ###"
fi

## NEC BMC Uninstall ##
esxcli software vib list |grep -i amsd
if [ $? -eq 0 ];then
	esxcli software vib remove -n amsd > /dev/null
	if [ $? -eq 0 ];then
		echo "### NEC AMSD Uninstalled  ###"
		esxcli software vib remove -n ilo > /dev/null
		if [ $? -eq 0 ];then
			echo "### NEC iLO Uninstalled  ###"
		else
			echo "### NEC iLO Not uninstall ###"
			exit 1
		fi
	else
		echo "### NEC AMSD Not uninstall ###"
		exit 1
	fi
else
	echo "### List not BMC vib ###"
fi
		
### Takeout Info ###
mkdir -p ${TV_DIR}
esxcli software vib list > ${TV_DIR}/pre-esxcli_software_vib_list.txt
esxcli system version get > ${TV_DIR}/pre-esxcli_system_version_get.txt
esxcli software profile get > ${TV_DIR}/pre-esxcli_software_profile_get.txt

### END ###
sync;sync

# /bin/reboot
echo "### Plese Reboot type in [ /bin/reboot ]"
echo "### $0 Shell END ###"
