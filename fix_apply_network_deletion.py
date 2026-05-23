with open('package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply', 'r') as f:
    text = f.read()

import re

# Fix network deletion
old_network_delete = """        elif [ -n "$old_secondary_subscriber_interface" ] && [ "$old_secondary_subscriber_interface" != "$subscriber_interface" ]; then
                uci -q delete network.${old_secondary_subscriber_interface}_dev
                uci -q delete network.$old_secondary_subscriber_interface
        fi"""

new_network_delete = """        elif [ -n "$old_secondary_subscriber_interface" ] && [ "$old_secondary_subscriber_interface" != "$subscriber_interface" ]; then
                case "$old_secondary_subscriber_interface" in
                        hotspot*)
                                uci -q delete network.${old_secondary_subscriber_interface}_dev
                                uci -q delete network.$old_secondary_subscriber_interface
                                ;;
                esac
        fi"""

text = text.replace(old_network_delete, new_network_delete)

# Fix dhcp deletion
old_dhcp_delete = """        elif [ -n "$old_secondary_subscriber_interface" ] && [ "$old_secondary_subscriber_interface" != "$subscriber_interface" ]; then
                uci -q delete dhcp.$old_secondary_subscriber_interface
        fi"""

new_dhcp_delete = """        elif [ -n "$old_secondary_subscriber_interface" ] && [ "$old_secondary_subscriber_interface" != "$subscriber_interface" ]; then
                case "$old_secondary_subscriber_interface" in
                        hotspot*) uci -q delete dhcp.$old_secondary_subscriber_interface ;;
                esac
        fi"""

text = text.replace(old_dhcp_delete, new_dhcp_delete)

# Fix firewall zone list deletion
old_fw_delete = """        elif [ -n "$old_secondary_subscriber_interface" ] && [ "$old_secondary_subscriber_interface" != "$subscriber_interface" ]; then
                uci -q del_list firewall.hotspot_openwrt_zone.network="$old_secondary_subscriber_interface" || true
        fi"""

new_fw_delete = """        elif [ -n "$old_secondary_subscriber_interface" ] && [ "$old_secondary_subscriber_interface" != "$subscriber_interface" ]; then
                uci -q del_list firewall.hotspot_openwrt_zone.network="$old_secondary_subscriber_interface" || true
                # it's safe to del_list from our own zone natively without pattern matching.
        fi"""

text = text.replace(old_fw_delete, new_fw_delete)

with open('package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply', 'w') as f:
    f.write(text)

