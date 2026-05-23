with open('package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot', 'r') as f:
    text = f.read()

import re

# Safen dhcp option removal
text = re.sub(
    r'case "\$options" in \*192\.168\.10\*\*\|\*192\.168\.20\*\*\|\*/hotspot\*\) uci -q delete "dhcp\.\$section\.dhcp_option" && mark_changed ;; esac',
    r'case "$options" in */hotspot*) uci -q delete "dhcp.$section.dhcp_option" && mark_changed ;; esac',
    text
)

text = re.sub(
    r'case "\$value" in \*192\.168\.10\*\*\|\*192\.168\.20\*\*\|\*/hotspot\*\) uci -q delete "dhcp\.\$section\.option114" && mark_changed ;; esac',
    r'case "$value" in */hotspot*) uci -q delete "dhcp.$section.option114" && mark_changed ;; esac',
    text
)

# Safen chilli section removal
text = re.sub(
    r'case "\$dhcpif:\$network" in\n\s*\*hotspot\*\|\*hotspot2\*\) delete_section "chilli\.\$section" ;;\n\s*esac',
    r'case "$dhcpif:$network" in\n                *hotspot_openwrt*|*" hotspot "*|*" hotspot2 "*) delete_section "chilli.$section" ;;\n        esac',
    text
)

with open('package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot', 'w') as f:
    f.write(text)
