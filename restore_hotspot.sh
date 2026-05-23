#!/bin/sh

# Function to safely get UCI values with a default
get_uci_val() {
    local val=$(uci -q get "$1")
    echo "${val:-$2}"
}

echo "--- Starting Hotspot Quick Restore ---"

# 1. Read setup.default values
HS_QUICK_SEC_ENABLED=$(get_uci_val "setup.default.hotspot_quick_secondary_enabled" "1")

# 2. Update setup.default
uci set setup.default.hotspot_quick_enabled='1'
uci set setup.default.initial_setup_complete='1'

# 3. Disable alemprator_firstboot IF IT EXISTS
if uci -q get alemprator_firstboot.@alemp[0] > /dev/null; then
    uci set alemprator_firstboot.@alemp[0].enabled='0'
    uci commit alemprator_firstboot
fi

# 4. Configure hotspot_openwrt.main using exact names found in setup.default
uci set hotspot_openwrt.main.enabled='1'
uci set hotspot_openwrt.main.quick_setup_enabled='1'
uci set hotspot_openwrt.main.quick_no_vlan='1'
uci set hotspot_openwrt.main.quick_runtime_dual_enabled="$HS_QUICK_SEC_ENABLED"

# Primary
uci set hotspot_openwrt.main.quick_ssid_primary=$(get_uci_val "setup.default.hotspot_quick_ssid_1" "Hotspot-1")
uci set hotspot_openwrt.main.quick_gateway_primary=$(get_uci_val "setup.default.hotspot_quick_gateway_1" "10.10.0.1")
uci set hotspot_openwrt.main.quick_pool_start_primary=$(get_uci_val "setup.default.hotspot_quick_pool_start_1" "10.10.0.10")
uci set hotspot_openwrt.main.quick_pool_end_primary=$(get_uci_val "setup.default.hotspot_quick_pool_end_1" "10.10.0.250")
uci set hotspot_openwrt.main.quick_policy_primary=$(get_uci_val "setup.default.hotspot_quick_policy_1" "standard")

# Secondary
uci set hotspot_openwrt.main.quick_ssid_secondary=$(get_uci_val "setup.default.hotspot_quick_ssid_2" "Hotspot-2")
uci set hotspot_openwrt.main.quick_gateway_secondary=$(get_uci_val "setup.default.hotspot_quick_gateway_2" "10.20.0.1")
uci set hotspot_openwrt.main.quick_pool_start_secondary=$(get_uci_val "setup.default.hotspot_quick_pool_start_2" "10.20.0.10")
uci set hotspot_openwrt.main.quick_pool_end_secondary=$(get_uci_val "setup.default.hotspot_quick_pool_end_2" "10.20.0.250")
uci set hotspot_openwrt.main.quick_policy_secondary=$(get_uci_val "setup.default.hotspot_quick_policy_2" "premium")

# Global/Other
uci set hotspot_openwrt.main.quick_wan_interface=$(get_uci_val "setup.default.hotspot_quick_wan_interface" "lan")
uci set hotspot_openwrt.main.quick_subscriber_interface='hotspot'
uci set hotspot_openwrt.main.subscriber_interface='hotspot'
uci set hotspot_openwrt.main.quick_subscriber_interface_secondary='hotspot2'

# Radius/General (if they exist)
uci set hotspot_openwrt.main.radius_server=$(get_uci_val "setup.default.hotspot_quick_radius_server" "")
uci set hotspot_openwrt.main.radius_secret=$(get_uci_val "setup.default.hotspot_quick_radius_secret" "")
uci set hotspot_openwrt.main.domain=$(get_uci_val "setup.default.hotspot_quick_domain" "hotspot.local")

# 5. Commit
uci commit setup
uci commit hotspot_openwrt

# 6. License Check
echo "--- License Check ---"
/usr/libexec/hotspot-openwrt/license-check
echo "license_exit: $?"

# 7. Apply
echo "--- Applying Changes ---"
APPLY_OUT=$(/usr/libexec/hotspot-openwrt/apply 2>&1)
APPLY_EXIT=$?
echo "$APPLY_OUT"
echo "apply_exit: $APPLY_EXIT"

# 8. Information Gathering
echo "--- Post-Apply Status ---"
echo "== package versions =="
opkg list-installed | grep -E '^(luci-app-setup|luci-app-hotspot-openwrt|alemprator-guard|coova-chilli) '
echo "== network hotspot =="
uci -q show network | grep -E 'hotspot'
echo "== wireless hotspot =="
uci -q show wireless | grep -E 'hotspot'
echo "== chilli =="
uci -q show chilli
echo "== ip addr =="
ip -br addr
echo "== processes =="
ps | grep chilli | grep -v grep
