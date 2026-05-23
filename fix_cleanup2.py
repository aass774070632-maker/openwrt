with open('package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot', 'r') as f:
    text = f.read()

import re

# We will just replace the exact block
old_block = """        case "$networks:$ssid" in
                *' hotspot '*|*' hotspot2 '*|*Hotspot*|*hotspot*) delete_section "wireless.$section" ;;
        esac"""

new_block = """        case "$networks" in
                *' hotspot '*|*' hotspot2 '*) delete_section "wireless.$section" ;;
        esac"""

text = text.replace(old_block, new_block)

old_firewall = """        case "$section:$name:$path:$src:$dest:$networks:$src_ip:$dest_ip" in
                *hotspot*|*Hotspot*|*br-hotspot*|*tun0*|*tun1*|*192.168.10*|*192.168.20*) delete_section "firewall.$section" ;;
        esac"""

new_firewall = """        case "$name" in
                hotspot_openwrt_*|hotspot-openwrt-*) delete_section "firewall.$section" ;;
        esac"""

text = text.replace(old_firewall, new_firewall)

with open('package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot', 'w') as f:
    f.write(text)

