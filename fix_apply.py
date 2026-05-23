with open('package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply', 'r') as f:
    text = f.read()

import re

# We shouldn't blindly delete confdir and addnhosts, we should just make sure they point to the right things
# or set them, not delete them if they exist and are correct or not ours to delete. Let's just set them if needed.

# But actually, hotpsot script is trying to make sure dnsmasq reads its conf file and hosts modifications,
# so removing `confdir` entirely will break all other OpenWrt packages that use `confdir`!

# So let's replace `uci -q delete dhcp.@dnsmasq[0].confdir` with appending its dir to confdir. Oh wait, /etc/dnsmasq.d is default openwrt confdir.
# OpenWrt dnsmasq default config has:
# config dnsmasq
#        ...
#        list confdir '/tmp/dnsmasq.d'  <-- sometimes
#        option confdir '/etc/dnsmasq.d' <-- often built in or just set
# deleting it forces it to default or breaks it!

old_block = """        chmod 0644 "$config_file" 2>/dev/null || true
        uci -q delete dhcp.@dnsmasq[0].confdir
        uci -q delete dhcp.@dnsmasq[0].addnhosts"""

new_block = """        chmod 0644 "$config_file" 2>/dev/null || true
        # Prevent destroying global dnsmasq features. OpenWrt uses confdir for many packages like adblock etc.
        # Just ensure dnsmasq.d is included if confdir missing, otherwise assume user/openwrt has it correct.
        if ! uci -q get dhcp.@dnsmasq[0].confdir >/dev/null; then
                uci -q set dhcp.@dnsmasq[0].confdir='/tmp/dnsmasq.d'
        fi"""

text = text.replace(old_block, new_block)

with open('package/luci-app-hotspot-openwrt/files/usr/libexec/hotspot-openwrt/apply', 'w') as f:
    f.write(text)

