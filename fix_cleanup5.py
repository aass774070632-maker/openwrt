with open('package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot', 'r') as f:
    text = f.read()

import re

# Wait, the previous python script fix_cleanup4.py failed to apply the dhcp options because of python escaping in regex!
# Look at the script above. The options are STILL *192.168.10*|*192.168.20*|*/hotspot*
# Let's fix that right now.

old_dhcp_options = """for section in $(uci -q show dhcp | sed -n "s/^dhcp\.\([^.=]*\)\.dhcp_option=.*$/\1/p" | sort -u); do
        options="$(uci -q get dhcp.$section.dhcp_option)"
        case "$options" in *192.168.10*|*192.168.20*|*/hotspot*) uci -q delete "dhcp.$section.dhcp_option" && mark_changed ;; esac
done

for section in $(uci -q show dhcp | sed -n "s/^dhcp\.\([^.=]*\)\.option114=.*$/\1/p" | sort -u); do
        value="$(uci -q get dhcp.$section.option114)"
        case "$value" in *192.168.10*|*192.168.20*|*/hotspot*) uci -q delete "dhcp.$section.option114" && mark_changed ;; esac
done"""

new_dhcp_options = """for section in $(uci -q show dhcp | sed -n "s/^dhcp\.\([^.=]*\)\.dhcp_option=.*$/\1/p" | sort -u); do
        options="$(uci -q get dhcp.$section.dhcp_option)"
        case "$options" in */hotspot*) uci -q delete "dhcp.$section.dhcp_option" && mark_changed ;; esac
done

for section in $(uci -q show dhcp | sed -n "s/^dhcp\.\([^.=]*\)\.option114=.*$/\1/p" | sort -u); do
        value="$(uci -q get dhcp.$section.option114)"
        case "$value" in */hotspot*) uci -q delete "dhcp.$section.option114" && mark_changed ;; esac
done"""

text = text.replace(old_dhcp_options, new_dhcp_options)

with open('package/luci-app-setup/files/usr/libexec/alemprator-setup/cleanup-hotspot', 'w') as f:
    f.write(text)
