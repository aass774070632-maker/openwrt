with open('package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot', 'r') as f:
    text = f.read()

import re
# We need to make the cleanup safer. Do not delete things just because they have 'hotspot' in the ssid or name unless it strictly matches known interfaces.
# Specially:
# case "$networks:$ssid" in
#    *' hotspot '*|*' hotspot2 '*|*Hotspot*|*hotspot*) delete_section "wireless.$section" ;;
# -> Instead, only delete if the section name is exactly wizard_hotspot etc, or if the network contains ' hotspot ' or ' hotspot2 '.
# Or better, don't delete based on SSID.

text = re.sub(r'case \"\$networks:\$ssid\" in\n.*?\*\' hotspot \'\*.*delete_section.*', 
              r'''case "$networks" in
                *' hotspot '*|*' hotspot2 '*) delete_section "wireless.$section" ;;
        esac''', text, flags=re.DOTALL)

with open('package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot', 'w') as f:
    f.write(text)

