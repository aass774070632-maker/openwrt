with open('package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot', 'r') as f:
    text = f.read()

import re

# Correct the wireless array check, to just match space padded words, not quotes.
text = re.sub(
    r'case "\$networks" in\n\s*\*\\\' hotspot \\\'\*\|\*\\\' hotspot2 \\\'\*\) delete_section "wireless.\$section" ;;\n\s*esac',
    r'case "$networks" in\n                *" hotspot "*|*" hotspot2 "*) delete_section "wireless.$section" ;;\n        esac',
    text
)
# If it failed to match with quotes due to python escaping:
text = text.replace("*\\' hotspot \\'*", '*" hotspot "*').replace("*\\' hotspot2 \\'*", '*" hotspot2 "*')
text = text.replace("*' hotspot '*|*' hotspot2 '*)", '*" hotspot "*|*" hotspot2 "*)')

# For DHCP, let's only delete if it strictly has "/hotspot" which is what actual coova chilli sets up for uam. 192.168.10 is too generic and breaks user subnets.
text = re.sub(
    r'case "\$options" in \*192\.168\.10\*\*\|\*192\.168\.20\*\*\|\*/hotspot\*\)',
    r'case "$options" in */hotspot*)',
    text
)
text = re.sub(
    r'case "\$value" in \*192\.168\.10\*\*\|\*192\.168\.20\*\*\|\*/hotspot\*\)',
    r'case "$value" in */hotspot*)',
    text
)

# For Firewall, it's safer to only match things that start with hotspot_openwrt or specifically named hotspot stuff from chilli.
text = re.sub(
    r'case "\$name:\$networks" in\n                \*hotspot\*\|\*hotspot2\*\)',
    r'case "$name:$networks" in\n                hotspot_openwrt_*|*" hotspot "*|*" hotspot2 "*)',
    text
)

with open('package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot', 'w') as f:
    f.write(text)
