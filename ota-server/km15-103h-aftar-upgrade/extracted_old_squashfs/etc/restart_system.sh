#!/bin/sh
#
# script file to restart system

RESTART_SYSTEM="$1"

if [ "$RESTART_SYSTEM" = "restart" ]; then
	echo reboot-system
	sleep 15
	reboot
elif [ "$RESTART_SYSTEM" = "factory" ]; then
	echo factorydefault-system
	mcr-cfgcli apply initfactory_tr069
elif [ "$RESTART_SYSTEM" = "config" ]; then
	echo configInit-system
	mcr-cfgcli apply initfactory_ConfigInit
elif [ "$RESTART_SYSTEM" = "ap" ]; then
	echo apInit-system
	mcr-cfgcli apply initConfig_1
	mcr-cfgcli apply restart_tr069
elif [ "$RESTART_SYSTEM" = "tr069" ]; then
	echo trInit-system
	mcr-cfgcli apply restart_tr069
else
	echo error
	mcr-cfgcli apply restart_tr069
fi

exit

