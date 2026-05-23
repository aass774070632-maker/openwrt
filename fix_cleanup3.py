with open('package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot', 'r') as f:
    text = f.read()

import re

# Safen wireless removal
text = re.sub(
    r'case "\$networks:\$ssid" in\n\s*\*\' hotspot \'\*\|\*\' hotspot2 \'\*\|\*Hotspot\*\|\*hotspot\*\) delete_section "wireless.\$section" ;;\n\s*esac',
    r'case "$networks" in\n                *\' hotspot \'*|*\' hotspot2 \'*) delete_section "wireless.$section" ;;\n        esac',
    text
)

# Safen dhcp removal
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

# Safen chilli removal
text = re.sub(
    r'case "\$tundev:\$dhcpif:\$network:\$uamlisten:\$net:\$dynip" in\n\s*\*tun0\*\|\*tun1\*\|\*hotspot\*\|\*hotspot2\*\|\*192\.168\.10\*\|\*192\.168\.20\*\) delete_section "chilli\.\$section" ;;\n\s*esac',
    r'case "$dhcpif:$network" in\n                *hotspot*|*hotspot2*) delete_section "chilli.$section" ;;\n        esac',
    text
)

# Safen firewall removal
text = re.sub(
    r'case "\$section:\$name:\$path:\$src:\$dest:\$networks:\$src_ip:\$dest_ip" in\n\s*\*hotspot\*\|\*Hotspot\*\|\*br-hotspot\*\|\*tun0\*\|\*tun1\*\|\*192\.168\.10\*\|\*192\.168\.20\*\) delete_section "firewall\.\$section" ;;\n\s*esac',
    r'case "$name:$networks" in\n                *hotspot*|*hotspot2*) delete_section "firewall.$section" ;;\n        esac',
    text
)

with open('package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot', 'w') as f:
    f.write(text)
