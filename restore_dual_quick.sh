#!/bin/sh

# UCI set for setup
uci set setup.default.hotspot_quick_enabled='1'
uci set setup.default.initial_setup_complete='1'

# Helper to get from setup.default or return default
get_setup_val() {
    local val=$(uci -q get setup.default."$1")
    [ -z "$val" ] && echo "$2" || echo "$val"
}

# Values for primary
ssid_p=$(get_setup_val "quick_ssid_primary" "Hotspot-Primary")
pool_start_p=$(get_setup_val "quick_pool_start_primary" "100")
pool_end_p=$(get_setup_val "quick_pool_end_primary" "250")
gw_p="192.168.10.1"

# Values for secondary
ssid_s=$(get_setup_val "quick_ssid_secondary" "Hotspot-Secondary")
pool_start_s=$(get_setup_val "quick_pool_start_secondary" "100")
pool_end_s=$(get_setup_val "quick_pool_end_secondary" "250")
gw_s="192.168.20.1"

radius_server=$(get_setup_val "radius_server" "127.0.0.1")
radius_secret=$(get_setup_val "radius_secret" "secret")
radius_auth_port=$(get_setup_val "radius_auth_port" "1812")
radius_acct_port=$(get_setup_val "radius_acct_port" "1813")

# Hotspot OpenWrt configuration
uci set hotspot_openwrt.main.enabled='1'
uci set hotspot_openwrt.main.quick_setup_enabled='1'
uci set hotspot_openwrt.main.quick_runtime_dual_enabled='1'
uci set hotspot_openwrt.main.quick_no_vlan='1'
uci set hotspot_openwrt.main.subscriber_interface='hotspot'
uci set hotspot_openwrt.main.quick_subscriber_interface='hotspot'
uci set hotspot_openwrt.main.quick_subscriber_interface_secondary='hotspot2'
uci set hotspot_openwrt.main.wan_interface='lan'
uci set hotspot_openwrt.main.quick_wan_interface='lan'

# Map missing fields for primary
uci set hotspot_openwrt.main.quick_gateway_primary="$gw_p"
uci set hotspot_openwrt.main.quick_pool_start_primary="$pool_start_p"
uci set hotspot_openwrt.main.quick_pool_end_primary="$pool_end_p"
uci set hotspot_openwrt.main.quick_ssid_primary="$ssid_p"

# Map missing fields for secondary
uci set hotspot_openwrt.main.quick_gateway_secondary="$gw_s"
uci set hotspot_openwrt.main.quick_pool_start_secondary="$pool_start_s"
uci set hotspot_openwrt.main.quick_pool_end_secondary="$pool_end_s"
uci set hotspot_openwrt.main.quick_ssid_secondary="$ssid_s"

# Radius and other fields
uci set hotspot_openwrt.main.radius_server="$radius_server"
uci set hotspot_openwrt.main.radius_secret="$radius_secret"
uci set hotspot_openwrt.main.radius_auth_port="$radius_auth_port"
uci set hotspot_openwrt.main.radius_acct_port="$radius_acct_port"

ba_time=$(uci -q get hotspot_openwrt.main.bridge_ageing_time)
[ -z "$ba_time" ] && uci set hotspot_openwrt.main.bridge_ageing_time='10'

uci commit setup
uci commit hotspot_openwrt

echo "== Validation =="
/usr/libexec/hotspot-openwrt/validate

echo "== Apply =="
/usr/libexec/hotspot-openwrt/apply

echo "== Status =="
/usr/libexec/hotspot-openwrt/status-json

echo "== Wireless =="
uci -q show wireless.wizard_hotspot_quick_primary
uci -q show wireless.wizard_hotspot_quick_secondary

echo "== Network =="
uci -q show network.hotspot
uci -q show network.hotspot2

echo "== Interfaces =="
ip -br addr show dev tun0 2>/dev/null || echo "tun0 missing"
ip -br addr show dev tun1 2>/dev/null || echo "tun1 missing"
ip -br addr show dev br-hotspot 2>/dev/null || echo "br-hotspot missing"
ip -br addr show dev br-hotspot2 2>/dev/null || echo "br-hotspot2 missing"

echo "== Versions =="
opkg list-installed | grep -E '^(luci-app-setup|luci-app-hotspot-openwrt|alemprator-guard|coova-chilli) '
