#!/bin/sh
OTA_SERVER="http://192.168.137.200:8080"
MODEL="km12-007"
CURRENT_VER=$(cat /etc/openwrt_release | grep DISTRIB_REVISION | cut -d"'" -f2)
MAC=$(cat /sys/class/net/br-lan/address 2>/dev/null || echo "unknown")
RESPONSE=$(curl -sf --max-time 20 "${OTA_SERVER}/api/check?model=${MODEL}&version=${CURRENT_VER}&mac=${MAC}")
UPDATE=$(echo "$RESPONSE" | grep -o '"update":true')
[ -z "$UPDATE" ] && exit 0
FW_URL=$(echo "$RESPONSE" | grep -o '"url":"[^"]*"' | cut -d'"' -f4)
curl -sf --max-time 300 -o /tmp/fw.bin "$FW_URL" && sysupgrade -n /tmp/fw.bin
