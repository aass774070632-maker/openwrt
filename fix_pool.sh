#!/bin/sh
uci set hotspot_openwrt.main.quick_pool_start_primary='192.168.10.100'
uci set hotspot_openwrt.main.quick_pool_end_primary='192.168.10.250'
uci set hotspot_openwrt.main.quick_pool_start_secondary='192.168.20.100'
uci set hotspot_openwrt.main.quick_pool_end_secondary='192.168.20.250'
uci commit hotspot_openwrt
/usr/libexec/hotspot-openwrt/apply
/usr/libexec/hotspot-openwrt/status-json
echo "== Interfaces =="
ip -br addr show dev tun0 2>/dev/null || echo "tun0 missing"
ip -br addr show dev tun1 2>/dev/null || echo "tun1 missing"
ip -br addr show dev br-hotspot 2>/dev/null || echo "br-hotspot missing"
ip -br addr show dev br-hotspot2 2>/dev/null || echo "br-hotspot2 missing"
