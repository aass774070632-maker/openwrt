#!/bin/sh
####################
# MTK 11AX mesh script for OpenWRT
# Controller
# 	SDK : /etc/mcr_mesh_set.sh start 1 wifi br-lan eth0 eth1 "ra0;apcli0;rax0;apclix0" "ra0;apcli0;rax0;apclix0"
# 	MCR : /etc/mcr_mesh_set.sh start 1 wifi br0 eth0 eth1 "ra0;apcli0;rax0;apclix0" "ra0;apcli0;rax0;apclix0"
# 	MCR : /etc/mcr_mesh_set.sh stop
# Agent
# 	SDK : /etc/mcr_mesh_set.sh start 2 wifi br-lan eth0 eth1 "ra0;apcli0;rax0;apclix0" "ra0;apcli0;rax0;apclix0"
# 	MCR : /etc/mcr_mesh_set.sh start 2 wifi br0 eth0 eth1 "ra0;apcli0;rax0;apclix0" "ra0;apcli0;rax0;apclix0"
# 	MCR : /etc/mcr_mesh_set.sh stop
#
# need update below files before shell start 
# /etc/wireless/mediatek/mt7915.dbdc.b0.dat
# /etc/wireless/mediatek/mt7915.dbdc.b1.dat
# /etc/hostapd_raXX_map.conf
# /etc/map/wts_bss_info_config
# /etc/map/1905d.cfg
# /etc/map/mapd_cfg
# /etc/map/mapd_user.cfg
# /etc/map/mapd_strng.conf

RED='\033[0;31m'
NC='\033[0m'

mapd_cfg_org="/etc/map/mapd_default.cfg"
p1905_file="/etc/map/1905d.cfg"
mapd_cfg_file="/etc/map/mapd_cfg"
mapd_user_file="/etc/map/mapd_user.cfg"
mapd_strng_file="/etc/map/mapd_strng.conf"
bh_file="/etc/conf/WLAN_MESH_BH_CONF"
mesh_log_enable_file="/tmp/mcr_wl_mesh_log_enable"

wappd_logging=0
p1905_logging=0
mapd_logging=0
####################
# prepare variables

sync_items()
{
	src_file=$1
	dst_file=$2
	need_loop=1
	line_count=1
	while [ $need_loop == "1" ]
	do
		line=`sed -n "$line_count"p ${src_file}`
		echo $line
		if [ -z $line ]
		then
			need_loop=0
		else
			key=`echo ${line} | awk -F "=" '{ print $1 }'`
			value=`echo ${line} | awk -F "=" '{ print $2 }'`
			# echo "Key = ${key}, value = ${value}"
			sed -i "s/${key}=.*/${key}=${value}/g" ${dst_file}
		fi
		line_count=`expr $line_count + 1`
	done
}

mapd_user_clear()
{
	#change to empty for new connect
	sed -i "s/BhProfile0Valid=.*/BhProfile0Valid=/g" ${mapd_user_file}
	sed -i "s/BhProfile1Valid=.*/BhProfile1Valid=/g" ${mapd_user_file}
	sed -i "s/BhProfile0Ssid=.*/BhProfile0Ssid=/g" ${mapd_user_file}
	sed -i "s/BhProfile0AuthMode=.*/BhProfile0AuthMode=/g" ${mapd_user_file}
	sed -i "s/BhProfile0EncrypType=.*/BhProfile0EncrypType=/g" ${mapd_user_file}
	sed -i "s/BhProfile0WpaPsk=.*/BhProfile0WpaPsk=/g" ${mapd_user_file}
	sed -i "s/BhProfile1Ssid=.*/BhProfile1Ssid=/g" ${mapd_user_file}
	sed -i "s/BhProfile1AuthMode=.*/BhProfile1AuthMode=/g" ${mapd_user_file}
	sed -i "s/BhProfile1EncrypType=.*/BhProfile1EncrypType=/g" ${mapd_user_file}
	sed -i "s/BhProfile1WpaPsk=.*/BhProfile1WpaPsk=/g" ${mapd_user_file}
	sed -i "s/BhProfile0Valid=.*/BhProfile0Valid=/g" ${mapd_user_file}
}

prepare_mapd_config()
{
	#mapd_cfg
	sed -i "s/lan_interface=.*/lan_interface=${lan_iface}/g" ${mapd_cfg_file}
	sed -i "s/wan_interface=.*/wan_interface=${wan_iface}/g" ${mapd_cfg_file}
	sed -i "s/DeviceRole=.*/DeviceRole=${role}/g" ${mapd_cfg_file}
	# mcr only
	sed -i "s/DhcpCtl=.*/DhcpCtl=0/g" ${mapd_cfg_file}
	sed -i "s/bss_config_priority=.*/bss_config_priority=${bss_priority_mapd}/g" ${mapd_cfg_file}

	if [ $role = "2" ]	#agent
	then
		# overwrite bh info if exist
		sync_items ${bh_file} ${mapd_user_file}
	fi
	# overwrite mapd_user.cfg -> mapd_cfg
	sync_items ${mapd_user_file} ${mapd_cfg_file}
}

prepare_config()
{
	br_mac=$(cat /sys/class/net/${br_iface}/address)
	ctrlr_al_mac=$br_mac
	agent_al_mac=$br_mac

	#check files
	if [ ! -f $mapd_cfg_org ]; then
		echo -e "${RED}Error: $mapd_cfg_org not exist. stop mesh init${NC}"
		exit 1
	else
		# mcr only
		echo 0 > /proc/zq_mcr_secure_policy
		cp ${mapd_cfg_org} ${mapd_cfg_file}
	fi
	if [ ! -f $mapd_cfg_file ]; then
		echo 0 > /proc/zq_mcr_secure_policy
		cp ${mapd_cfg_org} ${mapd_cfg_file}
	fi

	if [ ! -f $p1905_file ]; then
		echo -e "${RED}Error: $p1905_file not exist. stop mesh init${NC}"
		exit 1
	fi
	if [ ! -f $mapd_cfg_file ]; then
		echo -e "${RED}Error: $mapd_cfg_file not exist. stop mesh init${NC}"
		exit 1
	fi
	if [ ! -f $mapd_user_file ]; then
		echo -e "${RED}Error: $mapd_user_file not exist. stop mesh init${NC}"
		exit 1
	fi
	if [ ! -f $mapd_strng_file ]; then
		echo -e "${RED}Error: $mapd_strng_file not exist. stop mesh init${NC}"
		exit 1
	fi

	#1905d_cfg
	sed -i "s/lan=.*/lan=${lan_iface}/g" ${p1905_file}
	sed -i "s/wan=.*/wan=${wan_iface}/g" ${p1905_file}
	sed -i "s/br_inf=.*/br_inf=${br_iface}/g" ${p1905_file}
	sed -i "s/map_controller_alid=.*/map_controller_alid=${ctrlr_al_mac}/g" ${p1905_file}
	sed -i "s/map_agent_alid=.*/map_agent_alid=${agent_al_mac}/g" ${p1905_file}
	sed -i "s/bh_type=.*/bh_type=${bh_type}/g" ${p1905_file}
	sed -i "s/bss_config_priority=.*/bss_config_priority=${bss_priority_1905}/g" ${p1905_file}
	sed -i "s/radio_band=.*/radio_band=24G;5G;5G;/g" ${p1905_file}
	if [ $role = "1" ]
	then
		sed -i "s/map_agent=.*/map_agent=0/g" ${p1905_file}
		sed -i "s/map_root=.*/map_root=1/g" ${p1905_file}
	else
		sed -i "s/map_agent=.*/map_agent=1/g" ${p1905_file}
		sed -i "s/map_root=.*/map_root=0/g" ${p1905_file}
	fi

	prepare_mapd_config

	# for log (debug only)
#	wappd_logging=`cat ${mapd_user_file} | grep "MCR_FileLogging_wappd" | awk -F "=" '{ print $2 }'`
#	p1905_logging=`cat ${mapd_user_file} | grep "MCR_FileLogging_p1905" | awk -F "=" '{ print $2 }'`
#	mapd_logging=`cat ${mapd_user_file} | grep "MCR_FileLogging_mapd" | awk -F "=" '{ print $2 }'`
	if [ -f $mesh_log_enable_file ]; then
		echo ">>> MESH log Enabled >>>"
		wappd_logging=1
		p1905_logging=1
		mapd_logging=1
	else
		echo ">>> MESH log Disabled >>>"
	fi
}

####################
# shutdown
shutdown()
{
	rm -rf /tmp/wapp_ctrl
	killall -15 fwdd
	sleep 1
	killall mapd
	killall wapp
	killall p1905_managerd
	killall bs20
	killall -15 mapd
	killall -15 wapp
	killall -15 p1905_managerd
	killall -15 bs20

	rm /tmp/log_mapd
	rm /tmp/log_wappd
	rm /tmp/log_p1905
}
shutdown_apcli()
{
	echo ">>> ApCli Interface Down >>>"
	mcr-brctl delif ${br_iface} apcli0
	mcr-brctl delif ${br_iface} apclix0
	ifconfig apcli0 down
	ifconfig apclix0 down
}

# init modules
init_modules()
{
	rmmod mapfilter
	rmmod mtfwd
	mkdir -p /libmapd
	cp /usr/lib/libmapd_interface_client.so /libmapd/
	modprobe mapfilter

	mkdir -p /tmp/mtk/wifi
	ln -s /etc/wireless/mediatek/mt7915.dbdc.b0.dat /tmp/mtk/wifi/2860
	ln -s /etc/wireless/mediatek/mt7915.dbdc.b1.dat /tmp/mtk/wifi/rtdev
}

# init apcli
init_apcli()
{
	echo ">>> ApCli Interface Up >>>"
	# ifconfig apcli0 up
	# mcr-brctl addif ${br_iface} apcli0
	# iwpriv apcli0 set ApCliEnable=0
	# 5G only
	ifconfig apclix0 up
	mcr-brctl addif ${br_iface} apclix0
	iwpriv apclix0 set ApCliEnable=0
}

# set mapEnable
set_mapEnable()
{
	echo ">>> set mapEnable >>>"
	iwpriv ra0 set mapEnable=1
	iwpriv rax0 set mapEnable=1
	sleep 1
}

# startup mesh appclication
startup_app()
{
	echo ">>> startup mesh application >>>"
	if [ $wappd_logging = "1" ]
	then
		wapp -d1 -v2 -cra0 -crax0 >> /tmp/log_wappd
	else
		wapp -d1 -v2 -cra0 -crax0 > /dev/null
	fi
	sleep 1

	if [ $role = "1" ]
	then
		p1905_role=0
	else
		p1905_role=1
	fi

	if [ $p1905_logging = "1" ]
	then
		p1905_managerd -r${p1905_role} -f ${p1905_file} -F /etc/map/wts_bss_info_config >> /tmp/log_p1905&
	else
		p1905_managerd -r${p1905_role} -f ${p1905_file} -F /etc/map/wts_bss_info_config > /dev/null&
	fi
	sleep 1

	if [ $mapd_logging = "1" ]
	then
		mapd -I ${mapd_cfg_file} -O ${mapd_strng_file} >> /tmp/log_mapd&
	else
		mapd -I ${mapd_cfg_file} -O ${mapd_strng_file} > /dev/null&
	fi
}

dump_client()
{
	# echo 0 > /proc/zq_mcr_secure_policy
	wcli dump_topology dev
	# cat /tmp/dump.txt | grep -E 'STA MAC address|Client Address|BH STA|\"Medium\"' > /tmp/dump_client.txt
	sed -n -e '/STA MAC address/p' -e '/Client Address/p' -e '/BH STA/p' -e '/\"Medium\"/p' /tmp/dump.txt > /tmp/dump_client.txt
	awk -F '\"' '{ print $4 }' /tmp/dump_client.txt > /tmp/MESH_TOPOLOGY_INFO_CLIENT
	# echo 1 > /proc/zq_mcr_secure_policy
}

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

action=$1
role=$2
bh_type=$3
br_iface=$4
lan_iface=$5
wan_iface=$6
bss_priority_1905=$7
bss_priority_mapd=$8

#echo 0 > /proc/zq_mcr_secure_policy
if [ $action = "stop" ]
then
	echo ">>> mesh stop >>>"
	shutdown
	shutdown_apcli
	exit 1
elif [ $action = "app" ]
then
	echo ">>> mesh app start >>>"
	# test only
	startup_app
	exit 1
elif [ $action = "restart_app" ]
then
	echo ">>> mesh app restart $role >>>"
	shutdown
	set_mapEnable
	startup_app
	exit 1
elif [ $action = "sync" ]
then
	echo ">>> mesh sync $2 -> $3 >>>"
	sync_items $2 $3
	exit 1
elif [ $action = "bh_clear" ]
then
	echo ">>> mesh BH clear >>>"
	mapd_user_clear
	exit 1
elif [ $action = "dump_client" ]
then
	# echo ">>> dump topology info >>>"
	dump_client
	exit 1
else
	echo ">>> mesh init start DeviceRole:$role (0: Auto 1:Controller 2:Agent) br_iface:$br_iface >>>"
#	shutdown
#	shutdown_apcli
	echo 0 > /proc/zq_mcr_secure_policy
	prepare_config
	init_modules
	if [ $role = "2" ]	#agent
	then
		init_apcli
	fi
	set_mapEnable
	startup_app
	echo 1 > /proc/zq_mcr_secure_policy
	echo ">>> mesh init end >>>"
fi
